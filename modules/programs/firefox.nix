# Firefox policies and prefs — shared between desktop and hardened-vm.
# Managed-by-organisation UI is expected when NixOS sets enterprise policies.
# Hardening cherry-picks arkenfox ideas; this is not a full arkenfox port.
{
  programs.firefox = let
    lock = value: { Value = value; Status = "locked"; };
  in {
    enable = true;

    # "user" lets people override prefs in about:config; stock NixOS locks them.
    preferencesStatus = "user";

    preferences = {
      "browser.tabs.insertAfterCurrent" = true;
      "browser.aboutConfig.showWarning" = false;
      "browser.download.useDownloadDir" = true;
      "browser.sessionstore.interval" = 60000;
      # capacity is KiB; smart_size ignores it until disabled.
      "browser.cache.disk.enable" = true;
      "browser.cache.disk.smart_size.enabled" = false;
      "browser.cache.disk.capacity" = 2097152; # 2 GiB
      # VM guest /tmp is 2G tmpfs — this cache can fill it.
      "browser.cache.disk.parent_directory" = "/tmp/firefox-cache";
      # 1 = always use the native portal file picker on Linux.
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };

    policies = {
      DisableTelemetry = true;
      DisablePocket = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      # Keep Firefox Accounts available — pin so a profile cannot disable sync.
      DisableFirefoxAccounts = false;
      # 1Password extension handles logins.
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisableFormHistory = true;
      EncryptedMediaExtensions = {
        Enabled = true;
        Locked = true;
      };

      # Strict ETP (FF142+ Category locks the UI). FPP comes with Strict — do not add RFP on top.
      EnableTrackingProtection = {
        Category = "strict";
        BaselineExceptions = true;
        ConvenienceExceptions = true;
      };
      HttpsOnlyMode = "force_enabled";

      # Lock new-tab chrome so sponsored tiles and Pocket cannot come back.
      FirefoxHome = {
        Search = true;
        TopSites = true;
        SponsoredTopSites = false;
        Pocket = false;
        SponsoredPocket = false;
        SponsoredStories = false;
        Locked = true;
      };
      # FF146+: WebSuggestions false turns off urlbar Suggest entirely.
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

      # Desktop uses systemd-resolved + Cloudflare DoT. Firefox DoH would bypass that
      # (and on the VM, bypass Tor). Mode 5 = off.
      DNSOverHTTPS = {
        Enabled = false;
        Locked = true;
      };
      # DNS prefetch only — link prefetch and speculative connect are locked prefs below.
      NetworkPrediction = false;
      # Local AI is modules/ai, not Mozilla sidebar chat.
      GenerativeAI = {
        Enabled = false;
        Locked = true;
      };

      Preferences = {
        # media.ffmpeg.vaapi.enabled was removed (2025-02). This is the live Linux knob.
        # Does not disable HW decode outright — stops forcing it when blocklisted. Locked because
        # amdgpu VCN fence timeouts on RX 6700 XT when VA-API is forced.
        "media.hardware-video-decoding.force-enabled" = lock false;
        "media.av1.enabled" = lock true;
        "gfx.webrender.all" = lock true;
        # A profile once stuck software compositor on — caused UI jank.
        "gfx.webrender.software" = lock false;
        "gfx.canvas.accelerated" = lock true;

        "dom.ipc.forkserver.enable" = lock true;
        # Matches modules/network (IPv6 off).
        "network.dns.disableIPv6" = lock true;

        # arkenfox 1602: trim cross-origin referrers to scheme+host+port.
        "network.http.referer.XOriginTrimmingPolicy" = lock 2;
        # arkenfox 2619: show punycode for IDN homographs.
        "network.IDN_show_punycode" = lock true;
        # arkenfox 2620: PDF.js scripting has no policy key.
        "pdfjs.enableScripting" = lock false;
        # arkenfox 2606: remote pages cannot drive UITour.
        "browser.uitour.enabled" = lock false;
        # arkenfox 0601/0604/0801 — NetworkPrediction policy does not cover these.
        "network.prefetch-next" = lock false;
        "network.http.speculative-parallel-limit" = lock 0;
        "browser.urlbar.speculativeConnect.enabled" = lock false;
        # arkenfox 2003: keep WebRTC ICE on one interface (mDNS already hides LAN IP until grant).
        "media.peerconnection.ice.default_address_only" = lock true;
        # arkenfox 2603. Do not use StartDownloadsInTempDirectory — VM /tmp is 2G tmpfs.
        "browser.helperApps.deleteTempFileOnExit" = lock true;
        "privacy.userContext.enabled" = lock true;
        "privacy.userContext.ui.enabled" = lock true;

        # Must match font families in modules/desktop/fonts.nix.
        "font.default.x-western" = lock "sans-serif";
        "font.name.serif.x-western" = lock "Inter Nerd Font";
        "font.name.sans-serif.x-western" = lock "Inter Nerd Font";
        "font.name.monospace.x-western" = lock "JetBrainsMono Nerd Font Mono";
        "font.size.monospace.x-western" = lock 16;
      };

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
