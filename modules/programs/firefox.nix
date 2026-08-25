# Firefox — desktop (via programs/) and hardened-vm (imports this file only).
# NixOS: https://wiki.nixos.org/wiki/Firefox
# Policies: https://firefox-admin-docs.mozilla.org/  (legacy index: https://mozilla.github.io/policy-templates/)
# Using policies/preferences shows “managed by your organisation” — that is NixOS.
#
# Not an arkenfox port. https://github.com/arkenfox/user.js (v144)
# Cherry-pick only: official policy first, then prefs with no policy equivalent.
# Skipped on purpose: RFP (fights fonts/Dark Reader/theme), sanitize-on-shutdown
# (daily driver + Sync), disk-cache off (we want 2 GiB), captive portal off,
# Safe Browsing off, require_safe_negotiation (SETUP-WEB).
{
  programs.firefox = let
    lock = value: { Value = value; Status = "locked"; };
  in {
    enable = true;

    # NixOS default "locked". "user" = overridable in about:config.
    # https://search.nixos.org/options?query=programs.firefox.preferencesStatus
    preferencesStatus = "user";

    # ─── User preferences (overridable in about:config) ─────────────────────
    preferences = {
      # Official default false.
      "browser.tabs.insertAfterCurrent" = true;
      # Official default true.
      "browser.aboutConfig.showWarning" = false;
      # Official default true.
      "browser.download.useDownloadDir" = true;
      # Official default 15000 ms.
      "browser.sessionstore.interval" = 60000;
      # Official default true. capacity is KiB (256000 typical). smart_size
      # default true ignores capacity until disabled.
      # https://support.mozilla.org/en-US/questions/1270059
      "browser.cache.disk.enable" = true;
      "browser.cache.disk.smart_size.enabled" = false;
      "browser.cache.disk.capacity" = 2097152; # 2 GiB
      # Shared with VM: guest /tmp is 2G tmpfs — this can fill it.
      "browser.cache.disk.parent_directory" = "/tmp/firefox-cache";
      # 0=never 1=always 2=auto. Wiki: 1 = native portal picker.
      # https://wiki.nixos.org/wiki/Firefox
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };

    # ─── Policies (enterprise; UI cannot change) ────────────────────────────
    policies = {
      # Official defaults: telemetry/studies/Pocket on, default-browser check on.
      # DisablePocket is deprecated but still maps to extensions.pocket.enabled.
      DisableTelemetry = true;
      DisablePocket = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      # Official default false (Sync on). Pin so a profile cannot disable it.
      DisableFirefoxAccounts = false;
      # Official default true. 1Password extension handles logins.
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false; # also blocks about:logins
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisableFormHistory = true;
      # Policy unset = Firefox default (EME on). Enabled+Locked true pins it.
      EncryptedMediaExtensions = {
        Enabled = true;
        Locked = true;
      };

      # ETP Strict. Category (FF142+) overrides the other TP knobs and locks
      # the UI. FPP comes with Strict — do not add RFP on top.
      # https://firefox-admin-docs.mozilla.org/reference/policies/enabletrackingprotection/
      EnableTrackingProtection = {
        Category = "strict";
        BaselineExceptions = true;
        ConvenienceExceptions = true;
      };
      # Replaces locked dom.security.https_only_mode.
      # https://firefox-admin-docs.mozilla.org/reference/policies/httpsonlymode/
      HttpsOnlyMode = "force_enabled";

      # New-tab chrome. Locked so sponsored/Pocket cannot come back.
      # https://firefox-admin-docs.mozilla.org/reference/policies/firefoxhome/
      FirefoxHome = {
        Search = true;
        TopSites = true;
        SponsoredTopSites = false;
        Pocket = false;
        SponsoredPocket = false;
        SponsoredStories = false;
        Locked = true;
      };
      # US Suggest / urlbar ads. FF146+: WebSuggestions false turns Suggest off.
      # https://firefox-admin-docs.mozilla.org/reference/policies/firefoxsuggest/
      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
        Locked = true;
      };
      SearchSuggestEnabled = false;
      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        UrlbarInterventions = false;
        SkipOnboarding = true;
        MoreFromMozilla = false;
        FirefoxLabs = false;
        Locked = true;
      };

      # Desktop DNS is systemd-resolved + Cloudflare DoT. Firefox DoH would
      # bypass that (and on the VM, bypass Tor/system resolver). Mode 5 = off.
      # https://firefox-admin-docs.mozilla.org/reference/policies/dnsoverhttps/
      DNSOverHTTPS = {
        Enabled = false;
        Locked = true;
      };
      # DNS prefetch only. Link prefetch / speculative connect are prefs below.
      # https://firefox-admin-docs.mozilla.org/reference/policies/networkprediction/
      NetworkPrediction = false;
      # Local AI stack is modules/ai — not Mozilla sidebar chat.
      # https://firefox-admin-docs.mozilla.org/reference/policies/generativeai/
      GenerativeAI = {
        Enabled = false;
        Locked = true;
      };

      # ─── Locked preferences (no policy equivalent, or pin a default) ─────
      Preferences = {
        # media.ffmpeg.vaapi.enabled was removed (2025-02, bug 1949344). This is
        # the live Linux override. Official default false — does not disable HW
        # decode, only stops forcing it when gfxInfo blocklists. Locked so a
        # profile cannot force VA-API (amdgpu VCN fence timeout on RX 6700 XT).
        "media.hardware-video-decoding.force-enabled" = lock false;
        # Official default true. AV1 still software-decodes if HW decode is off.
        "media.av1.enabled" = lock true;
        "gfx.webrender.all" = lock true;
        # Profile once stuck this on → CPU compositor / UI jank.
        "gfx.webrender.software" = lock false;
        "gfx.canvas.accelerated" = lock true;

        # Official default true on Linux.
        "dom.ipc.forkserver.enable" = lock true;
        # Matches modules/network (IPv6 off). Official default false.
        "network.dns.disableIPv6" = lock true;

        # arkenfox 1602. Official default 0 (full URI). 2 = scheme+host+port.
        "network.http.referer.XOriginTrimmingPolicy" = lock 2;
        # arkenfox 2619. IDN homograph (xn-- apple lookalikes).
        "network.IDN_show_punycode" = lock true;
        # arkenfox 2620. Policy PDFjs has no EnableScripting key.
        "pdfjs.enableScripting" = lock false;
        # arkenfox 2606. Remote pages cannot drive UITour.
        "browser.uitour.enabled" = lock false;
        # arkenfox 0601/0604/0801. NetworkPrediction does not cover these.
        "network.prefetch-next" = lock false;
        "network.http.speculative-parallel-limit" = lock 0;
        "browser.urlbar.speculativeConnect.enabled" = lock false;
        # arkenfox 2003. mDNS already hides the LAN IP until device grant;
        # this keeps ICE on a single interface.
        "media.peerconnection.ice.default_address_only" = lock true;
        # arkenfox 2603. Complements Downloads dir (do not use
        # StartDownloadsInTempDirectory — VM /tmp is 2G tmpfs).
        "browser.helperApps.deleteTempFileOnExit" = lock true;
        # Built-in container tabs (no Multi-Account Containers add-on).
        "privacy.userContext.enabled" = lock true;
        "privacy.userContext.ui.enabled" = lock true;

        # Family names must match modules/desktop/fonts.nix.
        "font.default.x-western" = lock "sans-serif";
        "font.name.serif.x-western" = lock "Inter Nerd Font";
        "font.name.sans-serif.x-western" = lock "Inter Nerd Font";
        "font.name.monospace.x-western" = lock "JetBrainsMono Nerd Font Mono";
        "font.size.monospace.x-western" = lock 16;
      };

      # Firefox 139+: SearchEngines works on release, not only ESR.
      # Name + URLTemplate required.
      SearchEngines = {
        Add = [
          {
            Name = "Nix Packages";
            URLTemplate = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
            Alias = "@np";
          }
          {
            Name = "Nix Options";
            URLTemplate = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
            Alias = "@no";
          }
          {
            Name = "NixOS Wiki";
            URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
            Alias = "@nw";
          }
        ];
      };

      # force_installed = install and prevent uninstall.
      # 1Password add-on also lands on the VM (no 1Password app there).
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };
        "addon@darkreader.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        };
        "{4520dc08-80f4-4b2e-982a-c17af42e5e4d}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/tokyo-night-milav/latest.xpi";
        };
        "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
        };
        # https://addons.mozilla.org/firefox/addon/llmfeeder/  guid from AMO API
        "llmfeeder@j47.in" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/llmfeeder/latest.xpi";
        };
        "sponsorBlocker@ajay.app" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
        };
        "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/violentmonkey/latest.xpi";
        };
        "jid0-adyhmvsP91nUO8pRv0Mn2VKeB84@jetpack" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/raindropio/latest.xpi";
        };
      };
    };
  };
}
