// Keep track of which categories are collapsed / expanded
//  store the category states in a cookie
function storeCategoryTree() {
  // store each root category with any toggled subcategories
  var categories = {}

  // iterate through each category, creating an object to 
  //  store category's state information 
  $('.categories-nav > paper-item > li').each(function() {
    var root_id = $(this).attr("class").replace("cat-", "");

    categories[root_id] = [];

    $(this).find('li').each(function() {
      var value = $(this).attr("value");
      var id = $(this).attr("class").replace("cat-", "");

      if (value == "shown") {
        // add subcategory to root's list
        categories[root_id].push(id);
      }
    });
  }); 

  // create the menu state cookie
  document.cookie = "category_menu=" + JSON.stringify(categories);
}

// Load saved category collapsible menu state
function loadCategoryTree() {
  // Get the cookie for our category menu state
  var cookies = document.cookie.split(';');
  var categories;
  for (x in cookies) {
    if (cookies[x].indexOf("category_menu=") == 0) {
      categories = cookies[x].replace("category_menu=" ,"");
    }
  }
  // Toggle any root categories to previous saved state
  if (categories) {
    categories = JSON.parse(categories);
    for (root in categories) {
      if (categories[root].length > 0 ) {
        getSubCategories(root);
        for (x in categories[root]) {
          if (x < categories[root].length) {
            getSubCategories(categories[root][x]);
          }
        }
      }
    }
  }
  // remove the menu state cookie 
  document.cookie = "category_menu=;";
}

$(document).ready(function(){ 
  //loadCategoryTree();
});