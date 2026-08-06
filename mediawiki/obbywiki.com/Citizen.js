// Citizen.js
// needs a heavy refactor

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
