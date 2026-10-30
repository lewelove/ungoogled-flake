{
  pkgs,
  lib,
}:
let
  version = "1.75.0";

  filterLists = [
    "user-filters"
    "ublock-filters"
    "ublock-badware"
    "ublock-privacy"
    "ublock-unbreak"
    "ublock-quick-fixes"
    "easylist"
    "adguard-generic"
    "adguard-mobile"
    "easyprivacy"
    "adguard-spyware-url"
    "block-lan"
    "urlhaus-1"
    "plowe-0"
    "dpollock-0"
    "adguard-cookies"
    "ublock-cookies-adguard"
    "fanboy-cookiemonster"
    "ublock-cookies-easylist"
    "adguard-social"
    "fanboy-social"
    "fanboy-thirdparty_social"
    "adguard-popup-overlays"
    "adguard-mobile-app-banners"
    "adguard-other-annoyances"
    "adguard-widgets"
    "easylist-annoyances"
    "easylist-chat"
    "easylist-newsletters"
    "easylist-notifications"
    "ublock-annoyances"
    "fanboy-ai-suggestions"
    "RUS-0"
  ];

  userFiltersText = ''
    ! Google AI Studio

    !aistudio.google.com##.ng-star-inserted.two-row-by-two-col-layout.ng-trigger-fadeInOut.ng-trigger.ng-tns-c2952524442-5.promo-gallery
    !aistudio.google.com##.ng-star-inserted.two-row-by-two-col-layout.ng-trigger-fadeInOut.ng-trigger.ng-tns-c3449494382-6.promo-gallery
    !aistudio.google.com##.promo-gallery-container

    ! Gemini

    gemini.google.com##.announcement-banner-container
    gemini.google.com##.ng-star-inserted.ng-trigger-jumpstarterEntryAnimation.ng-trigger.ng-tns-c4093191533-9.jumpstarter

    ! Photopea Settings

    photopea.com##+js(set-constant, ___osw, undefined)
    photopea.com##.app > div[style^="padding: 10px"][style*="overflow: hidden; z-index:"]:has(> a + img)
    photopea.com##div[style^="padding-top: 10px; overflow: hidden; padding-left:"] > img
    photopea.com##div[style^="padding-top: 10px; overflow: hidden; padding-left:"] > a[target="_blank"] > img
    @@||photopea.com/promo/no_ads.png
    www.photopea.com##button.fitem:nth-of-type(7)
    www.photopea.com##button.fitem:nth-of-type(8)
    www.photopea.com##button.fitem:nth-of-type(6)
    www.photopea.com##.confirm.window

    ! GitHub Font Settings
    github.com##html:style(--fontStack-sansSerif: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif !important;)
    github.com##html:style(--fontStack-monospace: "CommitMono Nerd Font", "CommitMono", monospace !important; --font-monospace: "CommitMono Nerd Font", "CommitMono", monospace !important;)

    ! Hacker News
    news.ycombinator.com###hnmain:style(width: 30% !important; min-width: 400px !important)

    ! Aug 14, 2025 https://listenbrainz.org
    listenbrainz.org###brainz-player
    listenbrainz.org##.volume

    ! Aug 14, 2025 https://rutracker.org
    rutracker.org##div.bn-idx:nth-of-type(1)
    rutracker.org##div.bn-idx:nth-of-type(3)
    rutracker.org###sidebar1_wrap > .ext-links.bn-idx
    rutracker.org###idx-sidebar2 > .ext-links.bn-idx
    rutracker.org###idx-sidebar2 > div
    rutracker.org##.avatar
    rutracker.org##.nick-author.nick
    rutracker.org##.poster-flag
    rutracker.org##.nick
    rutracker.org##.post-time

    ! 15 Aug 2025 https://letterboxd.com
    letterboxd.com##.js-hide-in-app.banner-950.banner
    letterboxd.com##.film-news.section-margin

    ! 22 Aug 2025 https://vault.bitwarden.com
    vault.bitwarden.com###premium-banner

    ! 23 Aug 2025 https://mail.yandex.com
    mail.yandex.com##[class*="MultistepSidebarCarousel"]

    ! 24 Aug 2025 https://vk.com
    vk.com##.ConvoListFilter
    vk.com##.left_menu_nav_wrap
    vk.com##.LegalRecommendationsLinkLeftMenuAuthorized
    vk.com##.WideSeparator--legalRecommendationsLink.WideSeparator
    vk.com###businessNotify

    ! Sep 7, 2025 https://vk.com
    vk.com###friends_right_blocks_root > .vkui__root
    market.yandex.ru##[id*="content/header"][id*="madvHeaderPromo"]

    ! Sep 9, 2025 https://vk.com
    vk.com##.apps_feedRightAppsBlock__row
    vk.com##.apps_feedRightAppsBlock_single_app--.apps_feedRightAppsBlock_single_app.apps_feedRightAppsBlock.page_block

    ! Sep 9, 2025 https://www.youtube.com
    www.youtube.com##.sponsorBlockCategoryPill

    ! Oct 8, 2025 https://minerstat.com
    minerstat.com##.playTotemancer

    ! Nov 5, 2025 https://www.youtube.com
    !www.youtube.com##.ytd-app.style-scope.with-chipbar
    !www.youtube.com##ytd-mini-guide-entry-renderer.ytd-mini-guide-renderer.style-scope:nth-of-type(2)
    !www.youtube.com##ytd-guide-section-renderer.ytd-guide-renderer.style-scope:nth-of-type(3)

    ! Nov 6, 2025 https://www.youtube.com
    !www.youtube.com##.ytp-fullscreen-grid-stills-container
    !www.youtube.com###expandable-metadata > .ytd-watch-flexy.style-scope

    ! Nov 6, 2025 https://www.goodreads.com
    www.goodreads.com##.uitext.smallText.greyText > .minirating
    www.goodreads.com##.uitext.smallText
    www.goodreads.com##.wtrRating.ratingStars

    ! Nov 6, 2025 https://www.youtube.com
    !www.youtube.com##.ytd-watch-flexy.style-scope > .ytd-expandable-metadata-renderer.style-scope
    !www.youtube.com###flexible-item-buttons > yt-button-view-model.ytd-menu-renderer

    ! Nov 18, 2025 https://deepwiki.com
    deepwiki.com##.md\:right-0.md\:left-0.md\:bottom-4.mt-2.right-2.left-2.bottom-2.fixed.pointer-events-none

    ! Nov 20, 2025 https://aistudio.google.com
    ! aistudio.google.com##.token-count-container

    ! Nov 27, 2025 https://www.youtube.com
    !www.youtube.com###related
    !www.youtube.com###secondary
    !www.youtube.com###description-inline-expander > .ytd-watch-metadata.style-scope

    ! Jan 4, 2026 https://aistudio.google.com
    aistudio.google.com##.ng-star-inserted.add-media-button

    ! Jan 29, 2026 https://www.kimi.com
    www.kimi.com##.show-case-container
    www.kimi.com##.case-list

    ! Jan 30, 2026 https://aistudio.google.com
    aistudio.google.com##.search-entry-container-description
    aistudio.google.com##.search-entry-container-title
    aistudio.google.com##.ng-star-inserted.chat-hallucinations-disclaimer

    ! Feb 21, 2026 https://aistudio.google.com
    aistudio.google.com##.ng-star-inserted.banner-container

    ! Apr 17, 2026 https://aistudio.google.com
    aistudio.google.com##.upgrade-card-wrapper

    ! Apr 21, 2026 https://peel.fandom.com
    peel.fandom.com##.page__right-rail

    ! Apr 23, 2026 https://musicbrainz.org
    musicbrainz.org##.c.rating

    ! Apr 8, 2026 https://rutracker.org
    rutracker.org##.avatar
    rutracker.org##.poster-flag
    rutracker.org##.nick-author.nick
    rutracker.org##.nick
    rutracker.org##.rank_img

    ! Apr 9, 2026 https://rutracker.org
    rutracker.org##.sig-body
    rutracker.org##.post_btn_2
    rutracker.org###thx-block > .sp-wrap
    rutracker.org###thx-btn-div

    ! May 30, 2026 https://www.youtube.com
    www.youtube.com##ytd-rich-section-renderer.ytd-rich-grid-renderer.style-scope:nth-of-type(1)
    www.youtube.com##ytd-rich-section-renderer.ytd-rich-grid-renderer.style-scope:nth-of-type(2)

    ! Jun 1, 2026 https://www.youtube.com
    www.youtube.com##grid-shelf-view-model.ytd-item-section-renderer.ytGridShelfViewModelHost

    ! Jun 29, 2026 https://www.youtube.com
    www.youtube.com##ytd-rich-section-renderer.ytd-rich-grid-renderer.style-scope:nth-of-type(3)
    www.youtube.com##ytd-rich-section-renderer.ytd-rich-grid-renderer.style-scope:nth-of-type(4)

    ! Jul 13, 2026 https://www.youtube.com
    !www.youtube.com##.ytd-app.style-scope.with-chipbar
    !www.youtube.com###buttons > ytd-button-renderer.ytd-masthead.style-scope

    ! Oct 11, 2026 https://rutracker.org
    rutracker.org###latest_news > .w100 > tbody > tr

    ! Oct 15, 2026 https://www.youtube.com
    www.youtube.com###comments

    ! Oct 15, 2026 https://aistudio.google.com
    aistudio.google.com##.ng-star-inserted.promo-card-wrapper
  '';

  userFilters = lib.filter (line: line != "") (lib.splitString "\n" userFiltersText);

  adminSettings = {
    userSettings = {
      webrtcIPAddressHidden = true;
      userFiltersTrusted = true;
    };
  };

  managedSettings = {
    adminSettings = builtins.toJSON adminSettings;
    toOverwrite = {
      filters = userFilters;
      filterLists = filterLists;
    };
  };

  chromiumExtension = pkgs.stdenv.mkDerivation {
    pname = "ublock-origin";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/gorhill/uBlock/releases/download/${version}/uBlock0_${version}.chromium.zip";
      hash = "sha256-OTz5VwnRB01AIpcOkBTkNDlcU6giOH8eJfQ76Xz0tYI=";
    };

    nativeBuildInputs = [ pkgs.unzip ];
    unpackPhase = "unzip $src -d .";

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r uBlock0.chromium/* $out/

      substituteInPlace $out/js/vapi-background.js \
        --replace-fail \
          "bin = await vAPI.storage.get('cachedManagedStorage') || {};" \
          "bin = {};"

      runHook postInstall
    '';
  };

  chromiumExtensionId =
    let
      hex = builtins.substring 0 32 (builtins.hashString "sha256" "${chromiumExtension}");

      hexDigit =
        c:
        builtins.head (
          builtins.filter (i: builtins.substring i 1 "0123456789abcdef" == c) (builtins.genList (i: i) 16)
        );
    in
    builtins.concatStringsSep "" (
      builtins.genList (
        i: builtins.substring (hexDigit (builtins.substring i 1 hex)) 1 "abcdefghijklmnop"
      ) 32
    );

  policy = {
    "3rdparty".extensions.${chromiumExtensionId} = managedSettings;
  };
in
{
  name = "ublock-origin";
  inherit version;

  extension = chromiumExtension;
  id = chromiumExtensionId;
  inherit policy;
}
