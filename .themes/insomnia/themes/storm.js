const { theme } = require('./dark.js');

module.exports = {
  name: 'tokyo-night-storm',
  displayName: 'Tokyo Night Storm',
  theme: {
    rawCss: theme.rawCss,
    background: {
      default: '#24283b',
      success: '#00bad9',
      notice: '#9dcc63',
      warning: '#ff9e64',
      danger: '#f7768e',
      surprise: '#bb9af7',
      info: '#75a5fa',
    },
    foreground: {
      default: '#a9b1d6',
      success: '#24283b',
      notice: '#24283b',
      warning: '#24283b',
      danger: '#24283b',
      surprise: '#24283b',
      info: '#24283b',
    },
    highlight: {
      default: 'rgba(98, 114, 164, 1)',
      xxs: 'rgba(98, 114, 164, 0.05)',
      xs: 'rgba(98, 114, 164, 0.1)',
      sm: 'rgba(98, 114, 164, 0.2)',
      md: 'rgba(98, 114, 164, 0.4)',
      lg: 'rgba(98, 114, 164, 0.6)',
      xl: 'rgba(98, 114, 164, 0.8)',
    },
    styles: {
      sidebar: {
        background: {
          default: '#1e2436',
        },
      },
      dialog: {
        background: {
          default: '#1e2436',
        },
      },
      paneHeader: {
        background: {
          default: '#1e2436',
          success: '#73daca',
          notice: '#FFC36D',
          warning: '#ff9e64',
          danger: '#f7768e',
          surprise: '#bb9af7',
          info: '#75a5fa',
        },
      },
      transparentOverlay: {
        background: {
          default: 'rgba(0, 0, 0, 0.5)',
        },
      },
    },
  },
};
