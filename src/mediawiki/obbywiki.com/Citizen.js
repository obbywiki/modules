// Citizen.js
// needs a heavy refactor

// configs
const DISCORD_INVITE_URL = 'https://discord.gg/vuJsnzKkKY';

/**
 * @name SidebarIcons
 * Prepend icons to the MediaWiki sidebar (also needs a refactor!)
*/

const icons_by_ids = {
    'randomobby': {
        class: 'mw-ui-icon-controller',
    },
    'randomstudio': {
        class: 'mw-ui-icon-controller',
    },
    'randomwiki': {
        class: 'mw-ui-icon-controller',
    }
}

for (const [k, v] of Object.entries(icons_by_ids)) {
    const element = document.querySelector('.citizen-menu__content ' + '#n-' + k + ' a')
    if (!element) { continue }

    const icon_element = document.createElement('span')
    icon_element.classList.add('citizen-ui-icon', v.class)

    element.prepend(icon_element)
}

/**
 * @name LinkifyYears
 * Automatically hyper-link years in the short description (#siteSub) to their respective Category:YYYY pages.
*/

(function () {
  const targetId = "siteSub";

  const linkifyYears = () => {
    const siteSub = document.getElementById(targetId);
    if (!siteSub) return;

    const yearRegex = /\b2\d{3}\b/g;

    if (siteSub.querySelector(".year-link")) return;

    const originalText = siteSub.textContent;
    if (yearRegex.test(originalText)) {
      const newHTML = originalText.replace(yearRegex, (year) => {
        const url = mw.util.getUrl("Category:" + year);
        return `<a href="${url}" class="year-link" style="opacity: 0.7;">${year}</a>`;
      });
      siteSub.innerHTML = newHTML;
    }
  };

  linkifyYears();

  const observer = new MutationObserver(() => {
    linkifyYears();
  });

  const targetNode = document.getElementById(targetId);
  if (targetNode) {
    observer.observe(targetNode, { childList: true, characterData: true, subtree: true });
  }
})();

document.addEventListener('DOMContentLoaded', function () {
setTimeout(() => {
  document.querySelectorAll('.citizen-overflow-wrapper').forEach(wrapper => {
    if (wrapper.querySelector('.full-width')) {
      wrapper.style.maxWidth = 'none';
    }
  });
}, 250);
});

/**
 * @name DiscordHeaderButton
 * Animation adapted from https://github.com/wlft/discord-logo-2021
 */

const discord_button_html = `
<a
class="citizen-discord-button citizen-cdx-button--size-large cdx-button cdx-button--fake-button cdx-button--fake-button--enabled cdx-button--icon-only cdx-button--weight-quiet"
href="${DISCORD_INVITE_URL}"
title="Discord"
aria-label="ObbyWiki on Discord"
target="_blank"
rel="noopener noreferrer"
>
<svg class="citizen-discord-logo" viewBox="0 0 48 48" width="20" height="20" aria-hidden="true" focusable="false">
  <defs>
    <path
      id="citizen-discord-face"
      fill="currentColor"
      fill-rule="evenodd"
      transform="translate(2 2) scale(1.8333)"
      d="M20.317 4.3698a19.7913 19.7913 0 00-4.8851-1.5152.0741.0741 0 00-.0785.0371c-.211.3753-.4447.8648-.6083 1.2495-1.8447-.2762-3.68-.2762-5.4868 0-.1636-.3933-.4058-.8742-.6177-1.2495a.077.077 0 00-.0785-.037 19.7363 19.7913 0 00-4.8852 1.515.0699.0699 0 00-.0321.0277C.5334 9.0458-.319 13.5799.0992 18.0578a.0824.0824 0 00.0312.0561c2.0528 1.5076 4.0413 2.4228 5.9929 3.0294a.0777.0777 0 00.0842-.0276c.4616-.6304.8731-1.2952 1.226-1.9942a.076.076 0 00-.0416-.1057c-.6528-.2476-1.2743-.5495-1.8722-.8923a.077.077 0 01-.0076-.1277c.1258-.0943.2517-.1923.3718-.2914a.0743.0743 0 01.0776-.0105c3.9278 1.7933 8.18 1.7933 12.0614 0a.0739.0739 0 01.0785.0095c.1202.099.246.1981.3728.2924a.077.077 0 01-.0066.1276 12.2986 12.2986 0 01-1.873.8914.0766.0766 0 00-.0407.1067c.3604.698.7719 1.3628 1.225 1.9932a.076.076 0 00.0842.0286c1.961-.6067 3.9495-1.5219 6.0023-3.0294a.077.077 0 00.0313-.0552c.5004-5.177-.8382-9.6739-3.5485-13.6604a.061.061 0 00-.0312-.0286zM8.02 15.3312c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9555-2.4189 2.157-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.9555 2.4189-2.1569 2.4189zm7.9748 0c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9554-2.4189 2.1569-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.946 2.4189-2.1568 2.4189Z"
    />
    <mask id="citizen-discord-mask-outer">
      <rect width="100%" height="100%" fill="#fff"/>
      <circle r="42%" cx="50%" cy="50%" fill="#000"/>
    </mask>
    <mask id="citizen-discord-mask-middle">
      <rect width="100%" height="100%" fill="#000"/>
      <circle r="43%" cx="50%" cy="50%" fill="#fff"/>
      <circle r="32%" cx="50%" cy="50%" fill="#000"/>
    </mask>
    <mask id="citizen-discord-mask-inner">
      <rect width="100%" height="100%" fill="#000"/>
      <circle r="32%" cx="50%" cy="50%" fill="#fff"/>
    </mask>
  </defs>
  <use href="#citizen-discord-face" class="citizen-discord-logo__original"/>
  <use href="#citizen-discord-face" class="citizen-discord-logo__outer" mask="url(#citizen-discord-mask-outer)"/>
  <use href="#citizen-discord-face" class="citizen-discord-logo__middle" mask="url(#citizen-discord-mask-middle)"/>
  <use href="#citizen-discord-face" class="citizen-discord-logo__inner" mask="url(#citizen-discord-mask-inner)"/>
</svg>
<span>Discord</span>
</a>
`.trim();

function insert_discord_button() {
  if (document.getElementById('citizen-discord')) {
    return;
  }

  const header = document.querySelector('.citizen-header');
  if (!header) {
    return;
  }

  const item = document.createElement('div');
  item.id = 'citizen-discord';
  item.className = 'citizen-header__item citizen-discord';
  item.innerHTML = discord_button_html;

  const prefs = header.querySelector('.citizen-preferences-dropdown');
  const header_end = header.querySelector('.citizen-header__end');
  if (prefs && prefs.parentNode) {
    prefs.parentNode.insertBefore(item, prefs);
  } else if (header_end) {
    header_end.insertBefore(item, header_end.firstChild);
  } else {
    header.appendChild(item);
  }
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', insert_discord_button);
} else {
  insert_discord_button();
}
