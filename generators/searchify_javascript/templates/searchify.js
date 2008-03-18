var searchify_controller;

function searchify(facets) {
  searchify_controller = new Searchify(facets);
}

function searchify_submit() {
  $$('#searchify select').invoke('disable')
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

var Searchify = Class.create({
  initialize: function(facets) {
    this.facets = facets;
    this.rows = this.initial_rows();
    $('searchify').update(this.to_html());
  },

  to_html: function() {
    return "<div id='searchify_rows'>" + this.rows.invoke('to_html').join('') + "</div><a href='#' onclick='searchify_add_row()'>add</a>"
  },

  get_params: function() {
    var result = new Hash();
    var pairs = unescape(top.location.search.substring(1)).split(/\&/);
    pairs.each(function(pair) {
      var name_value = pair.split(/\=/)
      result.set(name_value[0], name_value[1]);
    });
    return result;
  },
  
  initial_rows: function() {
    var rows_from_params = this.rows_from_params();
    if (rows_from_params.length == 0) {
      return new Array(this.default_row());
    } else {
      return rows_from_params;
    }
  },
  
  default_row: function() {
    return new SearchifyRow(this, this.facets.first(), false);
  },
  
  rows_from_params: function() {
    var result = new Array();
    this.get_params().each(function(param) {
      facet = this.facet_with_name(param.key);
      if (facet) {
        result.push(new SearchifyRow(this, facet, param.value));
      }
    }, this);
    return result
  },
  
  index_of_row: function(row) {
    return this.rows.indexOf(row);
  },
  
  change_facet: function(element) {
    var index = element.id.split('_').last();
    this.rows[index].change_facet(this.facet_with_name(element.value));
  },
  
  facet_with_name: function(name) {
    for (var i=0; i<this.facets.length; ++i ) {
      if (this.facets[i].name == name) {
        return this.facets[i];
      }
    }
  },
  
  add_row: function() {
    var row = this.default_row();
    this.rows.push(row);
    $('searchify_rows').insert({ 'bottom': row.to_html() })
  },
  
  remove_row: function(index) {
    this.rows.splice(index, 1);
    $('searchify_row_' + index).remove();
  }
});

var SearchifyRow = Class.create({
  initialize: function(owner, facet, value) {
    this.owner = owner;
    this.facet = facet;
    this.value = value;
  },
  
  to_html: function() {
    return "<div class='searchify_row' id='searchify_row_" + this.index() + "'>" + this.facets_field() + " " + this.value_field()+ " " + this.remove_link() + "</div>";
  },
  
  remove_link: function() {
    return "<a href='#' onclick='searchify_remove_row(\"" + this.index() + "\")'>remove</a>";
  },
  
  facets_field: function() {
    return "<select size='1' id='" + this.facets_field_id() + "' onchange='searchify_change_facet(this)'>" + this.facet_options() + "</select>";
  },
  
  facets_field_id: function() {
    return "searchify_facets_" + this.index();
  },
  
  value_field_id: function() {
    return "searchify_value_" + this.index();
  },
  
  facet_options: function() {
    var result = "";
    this.owner.facets.each(function(facet) {
      result = result + this.facet_option(facet.name, facet.display);
    }, this);
    return result;
  },
  
  facet_option: function(name, display) {
    return "<option value='" + name + "'" + this.selected_option(name) + ">" + display + "</option>"
  },
  
  selected_option: function(name) {
    if (this.facet.name == name) {
      return " selected='selected'";
    } else {
      return '';
    }
  },
  
  value_field: function() {
    return "<span id='" + this.value_field_id() + "'>" + this.value_field_for_type(this.facet.type, this.facet.name) + "</span>";
  },
  
  value_field_for_type: function(type, name) {
    if (type == "text" || type == "string") {
      return "<input type='text' name='" + name + "' value='" + this.value + "' />"
    } else {
      return "not implemented yet"
    }
  },
  
  index: function() {
    return this.owner.index_of_row(this);
  },
  
  change_facet: function(new_facet) {
    this.facet = new_facet
    this.value = false;
    $(this.value_field_id()).update(this.value_field())
  }
})
