var searchify_controller;

function searchify(facets) {
  searchify_controller = new Searchify(facets);
}

function searchify_submit() {
  $('#searchify select.searchify_facets').attr('disabled', 'disabled');
  return true;
}

function searchify_change_facet(element) {
  searchify_controller.change_facet(element);
}

function searchify_add_row() {
  searchify_controller.add_row();
}

function searchify_remove_row(index) {
  searchify_controller.remove_row(index);
}

var Searchify = function(facets) {
  this.init(facets);
}
$.extend(Searchify.prototype, {
  init: function(facets) {
    this.facets = facets;
    this.rows = new Array();
    this.build_initial_rows();
    $('#searchify').html(this.to_html());
  },

  to_html: function() {
    return "<div id='searchify_rows'>" + $.map(this.rows, function(row, i) { return row.to_html() }).join('') + "</div><a href='#' onclick='searchify_add_row()'>add</a>";
  },

  get_params: function() {
    var result = new Array();
    var pairs = top.location.search.substring(1).split(/\&/);
    var self = this;
    $.each(pairs, function(index, pair) {
      var name_value = pair.split(/\=/);
      if (name_value.length == 2) {
        result.push([self.decode_url(name_value[0]), self.decode_url(name_value[1])]);
      }
    });
    return result;
  },

  decode_url: function(string) {
    return unescape(string.replace(/\+/g,"%20"));
  },

  build_initial_rows: function() {
    this.build_rows_from_params();
    if (this.rows.length == 0) {
      this.rows.push(this.default_row());
    }
  },

  default_row: function() {
    return new SearchifyRow(this, this.facets[0], false);
  },

  build_rows_from_params: function() {
    var self = this;
    $.each(this.get_params(), function(index, param) {
      facet = self.facet_with_name(param[0]);
      if (facet) {
        row = self.row_from_facet(facet);
        row.add_value(param[0], param[1]);
      }
    });
  },

  row_from_facet: function(facet) {
    for (var i=0; i<this.rows.length; ++i ) {
      if (this.rows[i].facet.name == facet.name) {
        return this.rows[i];
      }
    };
    var row = new SearchifyRow(this, facet);
    this.rows.push(row)
    return row;
  },

  index_of_row: function(row) {
    return this.rows.indexOf(row);
  },

  change_facet: function(element) {
    var index = element.id.split('_')[2];
    this.rows[index].change_facet(this.facet_with_name(element.value));
  },

  facet_with_name: function(name) {
    for (var i=0; i<this.facets.length; ++i ) {
      if (this.facets[i].name == name || name.indexOf(this.facets[i].name + '_') == 0) {
        return this.facets[i];
      }
    }
  },

  add_row: function() {
    var row = this.default_row();
    this.rows.push(row);
    $('#searchify_rows').append(row.to_html());
  },

  remove_row: function(index) {
    this.rows.splice(index, 1);
    $('#searchify_row_' + index).remove();
  }
});

var SearchifyRow = function(owner, facet) {
  this.init(owner, facet);
}
$.extend(SearchifyRow.prototype, {
  init: function(owner, facet) {
    this.owner = owner;
    this.facet = facet;
    this.values = {};
  },

  add_value: function(name, value) {
    this.values[this.strip_name(name)] = value;
  },

  strip_name: function(name) {
    if (name == this.facet.name) {
      return '';
    } else {
      return name.replace(this.facet.name + '_', '');
    }
  },

  to_html: function() {
    return "<div class='searchify_row' id='searchify_row_" + this.index() + "'>" + this.facets_field() + " " + this.value_field()+ " " + this.remove_link() + "</div>";
  },

  remove_link: function() {
    return "<a href='#' onclick='searchify_remove_row(\"" + this.index() + "\")'>remove</a>";
  },

  facets_field: function() {
    return "<select class='searchify_facets' size='1' id='" + this.facets_field_id() + "' onchange='searchify_change_facet(this)'>" + this.facet_options() + "</select>";
  },

  facets_field_id: function() {
    return "searchify_facets_" + this.index();
  },

  value_field_id: function() {
    return "searchify_value_" + this.index();
  },

  facet_options: function() {
    var options = this.owner.facets.map(function(facet) {
      return [facet.display, facet.name];
    });
    return this.select_menu_options(options, this.facet.name);
  },

  value_field: function() {
    return "<span id='" + this.value_field_id() + "'>" + this.value_field_for_type(this.facet.type) + "</span>";
  },

  value_field_for_type: function(type) {
    if (type == "text" || type == "string") {
      return this.text_field('', 24);
    } else if (type == "date" || type == "datetime") {
      return this.text_field('from', 10) + " - " + this.text_field('to', 10);
    } else if (type == "integer" || type == "float" || type == "decimal") {
      return this.operator_menu() + " " + this.text_field('', 8);
    } else if (type == "boolean") {
      return this.boolean_menu();
    }
  },

  text_field: function(name, size) {
    return "<input type='text' name='" + this.make_name(name) + "' value='" + this.escaped_value(name) + "' size='" + size + "' />";
  },

  boolean_menu: function() {
    return this.select_menu('', [['Any', '%'], ['Yes', '1'], ['No', '0']]);
  },

  operator_menu: function() {
    return this.select_menu('operator', [['Equal', '='], ['Less Than', '<='], ['Greater Than', '>=']]);
  },

  select_menu: function(name, options) {
    return "<select size='1' name='" + this.make_name(name) + "'>" + this.select_menu_options(options, this.escaped_value(name)) + "</select>";
  },

  select_menu_options: function(options, selected) {
    var self = this;
    return $.map(options, function(option, index) {
      return "<option value='" + option[1] + "'" + self.selected_option(option[1], selected) + ">" + option[0] + "</option>";
    }).join('');
  },

  selected_option: function(option_value, selected_value) {
    if (option_value == selected_value) {
      return " selected='selected'";
    } else {
      return '';
    }
  },

  make_name: function(suffix) {
    if (suffix == '') {
      return this.facet.name;
    } else {
      return this.facet.name + '_' + suffix;
    }
  },

  index: function() {
    return this.owner.index_of_row(this);
  },

  change_facet: function(new_facet) {
    this.facet = new_facet;
    $("#" + this.value_field_id()).html(this.value_field());
  },

  escaped_value: function(name) {
    var value = this.values[name] || '';
    return value.replace(/\"/g, '&#34;').replace(/\'/g, "&#39;");
  }
});
