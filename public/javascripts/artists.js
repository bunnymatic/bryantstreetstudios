$(function() {
  /** links to show/hide section on artist detail page */
  $('.sidebar a, .thumbs .piece').each(function() {
    var $content_blocks = $('section');
    var sxn = $(this).data('section');
    if (sxn) {
      $(this).on('click', function() {
        $content_blocks.each(function() {
          var $block = $(this);
          if ($block.hasClass(sxn)) {
            $block.show();
          }
          else if ($block.is(':visible')) {
            $block.hide();
          }
        });
      });
    }
  });
});
