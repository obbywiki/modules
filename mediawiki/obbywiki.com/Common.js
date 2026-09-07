$(document).ready(function() {
    
	if (mw.config.get('wgNamespaceNumber') === 0) {
    	$( '#ca-edit a' ).attr( 'href', '?veaction=editsource' );
    	$( '#ca-ve-edit a' ).attr( 'href', '?veaction=edit' );
	}
	
	// redlinks
	$('a.new').each(function () {
		var href = $(this).attr('href');
		
		if (href && href.indexOf('action=edit') !== -1) {
		  $(this).attr('href', href.replace('action=edit', 'veaction=edit'));
		}
	});
});

/**
 * Temporary UploadWizard replacement
*/

jQuery( function ( $ ) {
  $( '#t-upload' ).attr("href", "/wiki/Special:Upload");
});

var upload_link = document.querySelector('#t-upload > a');
if (upload_link) {
  upload_link.setAttribute('href', '/wiki/Special:Upload');
}
/**
 * Redirects %2527 to %27
*/

  var current = window.location.href;

  if (current.indexOf('%2527') !== -1) {
    var new_url = current.replace(/%2527/g, '%27');
    window.location.replace(new_url);
  }


// removes redlink params from User: pages
mw.hook('wikipage.content').add(function ($content) {
  $content.find('a.new[href*="User:"]').each(function () {
    var $link = $(this);
    var href = $link.attr('href');

    if (href) {
      $link.attr( 'href', href.replace(/[?&]veaction=edit(&redlink=1)?/g, '') );
    };
  });
});

// EXPERIMENTAL

// CAROUSEL (used in: Module:ObbyGameInfobox)
mw.hook('wikipage.content').add(function ($content) {
    const auto_advance_ms = 5000;
    const swipe_threshold_px = 50;
    const slide_transition = 'transform 0.4s cubic-bezier(0.25, 1, 0.5, 1)';
    const prefers_reduced_motion = window.matchMedia('(prefers-reduced-motion: reduce)');
    const carousels = $content.find('.infobox__carousel').not('.is-initialized');

    carousels.each(function () {
        const $carousel = $(this);
        $carousel.addClass('is-initialized');

        const $track = $carousel.find('.infobox__carousel-track');
        const $items = $carousel.find('.infobox__carousel-item');
        const item_count = $items.length;

        if (item_count <= 1) { return };

        let current_index = 0;
        let is_dragging = false;
        let start_x = 0;
        let autoplay_timer = null;
        let autoplay_remaining_ms = auto_advance_ms;
        let autoplay_started_at = 0;
        let is_hover_paused = false;

        if (item_count >= 6) {
            $carousel.addClass('infobox__carousel--many-thumbs');
        }

        const chevron_prev = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="15 18 9 12 15 6"></polyline></svg>';
        const chevron_next = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="9 18 15 12 9 6"></polyline></svg>';

        const $nav = $('<div class="infobox__carousel-nav"></div>');
        const $prev_btn = $('<button type="button" class="infobox__carousel-btn infobox__carousel-prev" aria-label="Previous thumbnail"></button>').html(chevron_prev);
        const $next_btn = $('<button type="button" class="infobox__carousel-btn infobox__carousel-next" aria-label="Next thumbnail"></button>').html(chevron_next);
        const $bars = $('<div class="infobox__carousel-bars"></div>');

        for (let i = 0; i < item_count; i++) {
            const $bar = $('<button type="button" class="infobox__carousel-bar"></button>');
            const $fill = $('<span class="infobox__carousel-bar-fill"></span>');

            $bar.attr('aria-label', 'Slide ' + (i + 1));
            if (i === 0) {
                $bar.addClass('infobox__carousel-bar--active');
            }

            $bar.append($fill);
            $bar.on('click', function (e) {
                e.preventDefault();
                go_to_slide(i);
            });

            $bars.append($bar);
        }

        $nav.append($prev_btn, $bars, $next_btn);
        $carousel.append($nav);

        function motion_reduced() {
            return prefers_reduced_motion.matches;
        }

        function track_transition() {
            return motion_reduced() ? 'none' : slide_transition;
        }

        function clear_autoplay() {
            if (autoplay_timer === null) { return };
            
            clearTimeout(autoplay_timer);
            autoplay_timer = null;
        }

        function schedule_autoplay() {
            clear_autoplay();
            if (is_hover_paused || is_dragging) { return };

            autoplay_started_at = Date.now();
            autoplay_timer = setTimeout(function () {
                autoplay_remaining_ms = auto_advance_ms;
                next_slide();
            }, autoplay_remaining_ms);
        }

        function pause_autoplay() {
            if (autoplay_timer === null) { return };
            autoplay_remaining_ms = Math.max(0, autoplay_remaining_ms - (Date.now() - autoplay_started_at));
            clear_autoplay();
        }

        function reset_autoplay() {
            autoplay_remaining_ms = auto_advance_ms;
            schedule_autoplay();
        }

        function go_to_slide(index) {
            current_index = index;
            update_carousel();
            reset_autoplay();
        }

        function update_bars() {
            $bars.children().each(function (j) {
                const $bar = $(this);
                const fill = $bar.find('.infobox__carousel-bar-fill').get(0);

                if (j === current_index) {
                    $bar.addClass('infobox__carousel-bar--active');
                    if (fill) {
                        fill.style.animation = 'none';
                        void fill.offsetWidth;
                        fill.style.animation = '';
                    }
                } else {
                    $bar.removeClass('infobox__carousel-bar--active');
                    if (fill) {
                        fill.style.animation = 'none';
                        fill.style.width = (j < current_index) ? '100%' : '0%';
                    }
                }
            });
        }

        function set_bar_play_state(play_state) {
            const fill = $carousel.find('.infobox__carousel-bar--active .infobox__carousel-bar-fill').get(0);
            if (fill) {
                fill.style.animationPlayState = play_state;
            }
        }

        function update_carousel() {
            $track.css({
                transition: track_transition(),
                transform: 'translateX(' + (-(current_index * 100)) + '%)'
            });

            update_bars();
        }

        function next_slide() {
            current_index = (current_index + 1) % item_count;
            update_carousel();
            reset_autoplay();
        }

        function prev_slide() {
            current_index = (current_index - 1 + item_count) % item_count;
            update_carousel();
            reset_autoplay();
        }

        $next_btn.on('click', function (e) {
            e.preventDefault();
            next_slide();
        });

        $prev_btn.on('click', function (e) {
            e.preventDefault();
            prev_slide();
        });

        $carousel.on('mouseenter', function () {
            is_hover_paused = true;
            pause_autoplay();
            set_bar_play_state('paused');
        });

        $carousel.on('mouseleave', function () {
            is_hover_paused = false;
            set_bar_play_state('running');
            schedule_autoplay();
        });

        $track.on('mousedown touchstart', drag_start);
        $track.on('mouseup touchend', drag_end);
        $track.on('mousemove touchmove', drag_action);
        $track.on('mouseleave', drag_end);

        function get_position_x(event) {
            return event.type.includes('mouse') ? event.pageX : event.originalEvent.touches[0].clientX;
        }

        function drag_start(event) {
            is_dragging = true;
            start_x = get_position_x(event);
            $carousel.addClass('is-dragging');
            pause_autoplay();
            $track.css('transition', 'none');
        }

        function drag_action(event) {
            if (!is_dragging) return;
            const current_x = get_position_x(event);
            const diff = current_x - start_x;
            const track_width = $carousel.width();
            const translate_offset = (diff / track_width) * 100;
            const current_percentage = -(current_index * 100) + translate_offset;

            $track.css('transform', 'translateX(' + current_percentage + '%)');
        }

        function drag_end(event) {
            if (!is_dragging) { return };
            is_dragging = false;
            $carousel.removeClass('is-dragging');
            $track.css('transition', track_transition());

            let end_x;
            if (event.type.includes('mouse')) {
                end_x = event.pageX;
            } else {
                end_x = event.originalEvent.changedTouches[0].clientX;
            }

            const diff = end_x - start_x;

            if (Math.abs(diff) > swipe_threshold_px) {
                if (diff > 0) prev_slide();
                else next_slide();
            } else {
                update_carousel();
                schedule_autoplay();
            }
        }

        schedule_autoplay();
    });
});





// ---

/* Any JavaScript here will be loaded for all users on every page load. */

mw.loader.using(['mediawiki.util'], function () {
    var applied_css_hashes = window.__obbywiki_applied_css_hashes || (window.__obbywiki_applied_css_hashes = {});

    function apply_import_css($content) {
        $content.find('span.import-css').each(function () {
            var $span = $(this);
            var css_text = $span.attr('data-css');
            var css_hash = $span.attr('data-css-hash') || css_text;

            if (!css_text || applied_css_hashes[css_hash]) {
                return;
            }

            applied_css_hashes[css_hash] = true;
            mw.util.addCSS(css_text);
        });
    }

    mw.hook('wikipage.content').add(apply_import_css);
});

/* replace index.php?title= with /wiki/ in Related Articles */
mw.loader.using(['mediawiki.util'], function () {
    'use strict';

    function fix_related_links($container) {
        var $links = $container.find('a[href*="/index.php?title="]:not([data-seo-fixed])');

        $links.each(function () {
            var $this = $(this);
            var href = $this.attr('href');
            
            var newHref = href.replace('/index.php?title=', '/wiki/');
            
            newHref = newHref.split('&')[0];

            $this.attr('href', newHref);
            $this.attr('data-seo-fixed', 'true');
        });
    }

    mw.hook('wikipage.content').add(function ($content) {
        if ($content.attr('class') === 'read-more-container' || $content.find('.read-more-container').length) {
            fix_related_links($content);
        }
    });

    var observer = new MutationObserver(function (mutations) {
        mutations.forEach(function (mutation) {
            if (mutation.addedNodes.length) {
                var $target = $(mutation.target).find('.read-more-container');
                if ($target.length) {
                    fix_related_links($target);
                }
            }
        });
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
});
