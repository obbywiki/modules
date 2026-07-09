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

const a = document.querySelector('#t-upload > a');

a.setAttribute('href', '/wiki/Special:Upload')

/**
 * Redirects %2527 to %27
*/

  var current = window.location.href;

  if (current.indexOf('%2527') !== -1) {
    var new_url = current.replace(/%2527/g, '%27');
    window.location.replace(new_url);
  }


// EXPERIMENTAL

/* Infobox Carousel Logic */
mw.hook('wikipage.content').add(function ($content) {
    const carousels = $content.find('.infobox__carousel').not('.is-initialized');

    carousels.each(function () {
        const $carousel = $(this);
        $carousel.addClass('is-initialized');

        const $track = $carousel.find('.infobox__carousel-track');
        const $items = $carousel.find('.infobox__carousel-item');
        const itemCount = $items.length;

        // If only one item, no need for controls
        if (itemCount <= 1) return;

        let currentIndex = 0;

        // Create Controls
        // Using Unicode arrows for simplicity and compatibility
        const $prevBtn = $('<button class="infobox__carousel-btn infobox__carousel-prev">\u276E</button>'); // ❮
        const $nextBtn = $('<button class="infobox__carousel-btn infobox__carousel-next">\u276F</button>'); // ❯
        const $indicators = $('<div class="infobox__carousel-indicators"></div>');

        // Generate indicators
        for (let i = 0; i < itemCount; i++) {
            const $dot = $('<div class="infobox__carousel-dot"></div>');
            if (i === 0) $dot.addClass('active');

            // Allow clicking dots to jump
            $dot.on('click', function (e) {
                e.preventDefault();
                goToSlide(i);
            });

            $indicators.append($dot);
        }

        $carousel.append($prevBtn, $nextBtn, $indicators);

        // Touch and Mouse Drag Support
        let isDragging = false;
        let startX = 0;
        let currentTranslate = 0;
        let prevTranslate = 0;
        // let animationID; // Unused
        // let autoSlideInterval; // Removed in favor of CSS animation sync

        // Drive auto-slide via CSS animation end event
        // The progress bar animation determines the timing. 
        // When it ends, we go to next slide.
        // Pausing is handled natively by CSS (animation-play-state: paused on hover).
        $carousel.on('animationend', '.infobox__carousel-dot.active', function (e) {
            if (e.originalEvent.animationName === 'carousel-progress') {
                nextSlide();
            }
        });

        // Core slide function
        function goToSlide(index) {
            currentIndex = index;
            updateCarousel();
        }

        function updateCarousel() {
            const translateX = -(currentIndex * 100);
            $track.css('transform', `translateX(${translateX}%)`);

            // Update dots
            $indicators.children().removeClass('active');
            $indicators.children().eq(currentIndex).addClass('active');
        }

        function nextSlide() {
            currentIndex = (currentIndex + 1) % itemCount;
            updateCarousel();
        }

        function prevSlide() {
            currentIndex = (currentIndex - 1 + itemCount) % itemCount;
            updateCarousel();
        }

        // Event Listeners for Buttons
        $nextBtn.on('click', function (e) {
            e.preventDefault();
            nextSlide();
        });

        $prevBtn.on('click', function (e) {
            e.preventDefault();
            prevSlide();
        });

        // Drag/Swipe Logic
        $track.on('mousedown touchstart', dragStart);
        $track.on('mouseup touchend', dragEnd);
        $track.on('mousemove touchmove', dragAction);
        $track.on('mouseleave', dragEnd);

        function getPositionX(event) {
            return event.type.includes('mouse') ? event.pageX : event.originalEvent.touches[0].clientX;
        }

        function dragStart(event) {
            isDragging = true;
            startX = getPositionX(event);
            $carousel.addClass('is-dragging');
            // CSS pause handles implicit pause if hovered/active due to interaction

            // Disable transition for instant follow
            $track.css('transition', 'none');
        }

        function dragAction(event) {
            if (!isDragging) return;
            const currentX = getPositionX(event);
            const diff = currentX - startX;
            const walk = diff * 1.5; // Sensitivity

            // Calculate potential translation
            // -currentIndex * 100 is base percentage. We need to convert pixel diff to percentage relative to track width
            const trackWidth = $carousel.width();
            const translateOffset = (diff / trackWidth) * 100;
            const currentPercentage = -(currentIndex * 100) + translateOffset;

            $track.css('transform', `translateX(${currentPercentage}%)`);
        }

        function dragEnd(event) {
            if (!isDragging) return;
            isDragging = false;
            $carousel.removeClass('is-dragging');
            $track.css('transition', 'transform 0.4s cubic-bezier(0.25, 1, 0.5, 1)'); // Restore transition

            // Determine if we dragged enough to change slide
            // We need the end X. For mouseup it is pageX, for touchend we need changedTouches 
            let endX;
            if (event.type.includes('mouse')) {
                endX = event.pageX;
            } else {
                endX = event.originalEvent.changedTouches[0].clientX;
            }

            const diff = endX - startX;
            const threshold = 50; // min pixels to swipe

            if (Math.abs(diff) > threshold) {
                if (diff > 0) prevSlide();
                else nextSlide();
            } else {
                updateCarousel(); // Snap back
            }

            // Resume auto slide if mouse leaves, but here we just wait for mouseleave event or separate interaction
            // To be safe, we don't immediately restart auto-slide if mouse is still technically possibly "over"
            // The mouseleave event on $carousel will handle restart.
        }
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
