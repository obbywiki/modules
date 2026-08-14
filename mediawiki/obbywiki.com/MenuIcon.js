// imported from https://dev.miraheze.org/w/index.php?title=User:Splatched/MenuIcon.js&action=raw&ctype=text/javascript 2026-08-14 (modified)
// thank you https://aurorcorporation.miraheze.org

(function() {
    'use strict';

    function runScript() {
		mw.loader.using(['mediawiki.util']).done(function () {
			function createPopout(config) {
				const popoutHeading = config.heading ? config.heading : 'Related wikis';
				const popoutIcon = config.icon ? config.icon : 'https://static.wikitide.net/utgwiki/2/2b/Collections_bookmark.svg';
				const popoutClass = config.icon ? 'citizen-popout-icon' : 'citizen-popout-icon invert-darkmode';
				
				const popoutWrapper = document.createElement('div');
				popoutWrapper.className = `citizen-popout citizen-header__item citizen-dropdown`;
				const itemsHTML = config.items.map(item => `
					<a href="${item.url}" target="_blank" rel="noopener noreferrer" class="citizen-popout__item" title="${item.name}">
						<img class="citizen-popout__icon" width="48" height="48" src="${item.icon ? `${item.icon}` : 'https://upload.wikimedia.org/wikipedia/commons/b/b7/Miraheze-Logo.svg'}" alt="${item.name} icon">
						<div class="citizen-popout__info">
							<div class="citizen-popout__name">${item.name}</div>
							${item.desc ? `<div class="citizen-popout__desc">${item.desc}</div>` : ''}
						</div>
					</a>
		
				`).join(``);
						popoutWrapper.innerHTML = `
					<details class="citizen-dropdown-details">
						<summary class="citizen-dropdown-summary citizen-cdx-button--size-large cdx-button cdx-button--fake-button cdx-button--fake-button--enabled cdx-button--icon-only cdx-button--weight-quiet" title="${popoutHeading}" aria-details="citizen-relatedwikis__card">
							<svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" aria-hidden="true" focusable="false" fill="currentColor"><path d="M153.78-47.78q-44.3 0-75.15-30.85-30.85-30.85-30.85-75.15v-572.44h106v572.44h572.44v106H153.78Zm186-186q-44.3 0-75.15-30.85-30.85-30.85-30.85-75.15v-466.44q0-44.3 30.85-75.15 30.85-30.85 75.15-30.85h466.44q44.3 0 75.15 30.85 30.85 30.85 30.85 75.15v466.44q0 44.3-30.85 75.15-30.85 30.85-75.15 30.85H339.78ZM534.7-526.22l100-60 100 60v-280h-200v280Z"/></svg>
						</summary>
					</details>
					<div id="citizen-relatedwikis__card" class="citizen-drawer__card citizen-popout__card citizen-menu__card">
						<div class="citizen-menu__heading">${popoutHeading}</div>
						<div class="citizen-menu__content">
							${itemsHTML}
						</div>
					</div>
				`;
				return popoutWrapper;
			}
			
			// Close popouts when clicking outside
			document.addEventListener('click', function (event) {
				document.querySelectorAll('.citizen-popout').forEach(popout => {
					const details = popout.querySelector('.citizen-dropdown-details');
			
					if (!popout.contains(event.target)) {
						details.removeAttribute('open');
					}
				});
			});
		
			// 1. Create and insert popout menus
			const target = document.querySelector('.citizen-header__inner');
			if (target && target.parentNode) {
				popoutData.forEach(relatedWikisConfig => {
					const popoutElement = createPopout(relatedWikisConfig);
					target.parentNode.insertBefore(popoutElement, target);
				});
			}
			
			// Close popouts when clicking outside
			document.addEventListener('click', function (event) {
				document.querySelectorAll('.citizen-popout').forEach(popout => {
					const details = popout.querySelector('.citizen-dropdown-details');
			
					if (!popout.contains(event.target)) {
						details.removeAttribute('open');
					}
				});
			});
		
			// 2. Inject consolidated CSS
			const style = document.createElement('style');
			style.textContent = `
				.citizen-popout {
					@media screen and (max-width: 600px) {
						display: none;
					}
					
					& .citizen-dropdown-summary {
						display: flex;
						align-items: center;
						justify-content: center;
						opacity: 1;
						transition: .25s opacity;
							
						@starting-style {
							opacity: 0;
						}
						
						img {
							pointer-events: none;
						}
					}
					
					.citizen-popout__info {
						display: flex;
						flex-direction: column;
					}
					
					.citizen-popout__name {
						font-weight: 600;
						font-size: var(--font-size-large);
						line-height: var(--line-height-large);
						color: var(--color-emphasized);
						margin-bottom: -2px;
					}
						
					.citizen-popout__desc {
						font-size: var(--font-size-small); 
						line-height: var(--line-height-small);
						color: var(--color-subtle);
					}
				}
				
				.citizen-popout__card {
					padding: var(--space-md);
					min-width: 20rem;
					
					& .citizen-menu__heading {
						padding-left: unset;
						padding-top: unset;
					}
					
					& img {
						aspect-ratio: 1;
						object-fit: contain;
					}
					
					& .citizen-menu__content {
						overflow: inherit;
						min-width: 20rem;
					}
				}
				
				@media screen and (min-width: 1120px) {
					.citizen-popout__card {
						top: 7rem;
					}
				}
				
				/* Popout Item Styles */
				.citizen-popout__item {
					display: flex;
					align-items: center;
					gap: var(--space-md);
					cursor: pointer;
					text-decoration: none;
					color: inherit;
					padding: var(--space-sm) var(--space-md);
					margin: var(--space-sm) -8px; /* Counteract padding to align with card edges */
					border-radius: var(--border-radius-base);
					
					&:first-child {
						margin-top: unset;
					}
					
					&:last-child {
						margin-bottom: unset;
					}
					
					.citizen-popout__icon {
						user-select: none;
					}
				
					&:hover {
						text-decoration: none; /* Explicitly removes underline on hover */
						background-color: var(--background-color-button-quiet--hover);
						
						.citizen-popout__desc {
							color: var(--color-emphasized);
						}
					}
					
					&:active {
				        background-color: var(--background-color-button-quiet--active);
				    }
				}
				
				.citizen-popout-icon.invert-darkmode {
					filter: var(--filter-invert);
				}
			`;
			document.head.appendChild(style);
		});
    }
    
    // --- THE CHECKER ---
    const checkData = setInterval(() => {
        // We check if the variable is defined in the global scope
        if (typeof popoutData !== 'undefined') {
            clearInterval(checkData);
            runScript();
        }
    }, 100); // Checks every 100ms

    // Safety timeout: stop looking after 10 seconds
    setTimeout(() => clearInterval(checkData), 10000);
})();