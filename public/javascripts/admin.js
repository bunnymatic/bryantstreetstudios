/* admin js */
$(function() {
  $('a.delete_link').bind('click', function() {
    if (confirm("Are you sure you want to delete this?")) {
      return true;
    } else {
      return false;
    }
  });

  /** show/hide content blocks controls on hover */
  $('table.content_blocks tbody tr td').hover(function() {
    $(this).closest('tr').find('.ctrls').toggleClass('hover');
  });
  
  /** add new picture form show */
  $('#admin_pictures .controls .add_new').bind('click', function() {
    $(this).closest('.controls').find('.add_new_form').toggle();
  });

  /** show/hide image controls on hover */
  $('#admin_pictures .picture').hover(function() {
    $(this).toggleClass('hover');
  });

  /** auto select all in url input on click */
  $('#admin_pictures .url input').bind('click', function() { $(this).select(); });

  /** use markdown js editor */
  $('#admin_content_block textarea.content_block').markItUp(mySettings);

  /** exclusions form show */
  $('#exclusions .controls .add_new').bind('click', function() {
    $(this).closest('.controls').find('form').toggle();
    return false;
  });

  /** show/hide image controls on hover */
  $('#exclusions ul li').hover(function() {
    $(this).toggleClass('hover');
  });


});