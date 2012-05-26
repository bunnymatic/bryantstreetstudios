/* admin js */
$(function() {
  $('a.delete_link').bind('click', function() {
    if (confirm("Are you sure you want to delete this?")) {
      return true;
    } else {
      return false;
    }
  });
});