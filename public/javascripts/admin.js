/* admin js */
$(function() {
  $('a.delete_link').bind('click', function() {
    if (confirm("Are you sure you want to delete this?")) {
      return true;
    } else {
      return false;
    }
  });

  /** show/hide controls on hover */
  $('table.content_blocks tbody tr').hover(function() {
    $(this).toggleClass('hover');
  });
});