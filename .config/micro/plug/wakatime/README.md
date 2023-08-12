# WakaTime for Micro Editor

[![Coding time tracker](https://wakatime.com/badge/github/wakatime/WakaTime.novaextension.png?branch=master)](https://wakatime.com/badge/github/wakatime/WakaTime.novaextension)

Metrics, insights, and time tracking automatically generated from your programming activity.

## Installation

> **_NOTE:_** Please [build Micro from source](https://github.com/zyedidia/micro#building-from-source) since the changes needed to have this plugin working haven't been released yet.

Using the plugin manager:

```shell
micro -plugin install wakatime
```

Or from within micro (must restart micro afterwards for the plugin to be loaded):

```shell
> plugin install wakatime
```

Or manually install by cloning this repo as `wakatime` into your `plug` directory:

```shell
git clone https://github.com/wakatime/micro-wakatime ~/.config/micro/plug/wakatime
```

For the first time you install WakaTime in your machine the Micro startup could delay a bit.

1. Enter your [api key](https://wakatime.com/api-key), then hit `Enter`.
    > (If you’re not prompted, press ctrl + e then type `wakatime.apikey`.)

2. Use Micro Editor and your coding activity will be displayed on your [WakaTime dashboard](https://wakatime.com).

## Usage

Visit https://wakatime.com to see your coding activity.

![Project Overview](https://wakatime.com/static/img/ScreenShots/Screen-Shot-2016-03-21.png)

## Configuring

Extension settings are stored in the INI file at `$HOME/.wakatime.cfg`.

More information can be found from [wakatime core](https://github.com/wakatime/wakatime#configuring).

## Troubleshooting

First, turn on debug mode:

1. Run micro with flag `-debug`.
    > Logs are only generated when running with debug flag. Any other previous logs haven't been recorded.

Next, navigate to the folder you started micro and open `log.txt`.

Errors outside the scope of this plugin go to `$HOME/.wakatime.log` from [wakatime-cli][wakatime-cli-help].

The [How to Debug Plugins][how to debug] guide shows how to check when coding activity was last received from your editor using the [Plugins Status Page][plugins status page].

For more general troubleshooting info, see the [wakatime-cli Troubleshooting Section][wakatime-cli-help].

[wakatime-cli-help]: https://github.com/wakatime/wakatime#troubleshooting
[how to debug]: https://wakatime.com/faq#debug-plugins
[plugins status page]: https://wakatime.com/plugin-status
