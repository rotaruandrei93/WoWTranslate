# WoWTranslate

**WoWTranslate** is a lightweight World of Warcraft addon that provides automatic chat translation directly inside the game.

It is designed to make communication easier in multilingual guilds, parties, and communities by translating chat messages without requiring users to manually copy and paste text into an external translator.

## Features

* 🌐 Automatic chat translation
* 💬 Translate supported in-game chat messages
* ⚡ Lightweight and unobtrusive
* 🔄 Translation directly within the WoW chat interface
* 🧩 Simple installation
* 🚫 No self-hosted server required
* 🔌 Uses a native DLL to communicate with the translation service

## Installation

WoWTranslate consists of **two components**:

* The `WoWTranslate` addon folder
* The `wowtranslate.dll` file

### 1. Install the addon

Copy the `WoWTranslate` folder into your WoW AddOns directory:

```text
World of Warcraft/
└── Interface/
    └── AddOns/
        └── WoWTranslate/
```

### 2. Install the DLL

Copy:

```text
wowtranslate.dll
```

into your **main World of Warcraft game directory**, alongside the game executable.

For example:

```text
World of Warcraft/
├── WoW.exe
├── wowtranslate.dll
├── dlls.txt
└── Interface/
    └── AddOns/
        └── WoWTranslate/
```

### 3. Add the DLL to `dlls.txt`

Open the `dlls.txt` file located in your World of Warcraft game directory.

Add the following line:

```text
wowtranslate.dll
```

If the file already contains other DLLs, add `wowtranslate.dll` on a new line.

### 4. Launch the game

Start World of Warcraft normally and make sure **WoWTranslate** is enabled in the AddOns menu.

The addon and DLL will work together automatically.

## Requirements

* A compatible **World of Warcraft 1.12.1 / Vanilla-based client**
* The WoWTranslate addon
* `wowtranslate.dll`
* A `dlls.txt` file containing:

```text
wowtranslate.dll
```

## How It Works

WoWTranslate consists of a standard WoW addon combined with a native DLL.

The addon handles the in-game interface and chat integration, while the DLL provides the functionality required to communicate with the translation service.

This approach allows WoWTranslate to provide automatic translation without requiring users to run their own server or additional external software.

## Translation Service

WoWTranslate uses an external translation service to process chat messages.

The translation backend may change between releases depending on availability, API limits, and compatibility. Users do not need to host or maintain their own translation server.

## Privacy

Messages submitted for translation are sent to the external translation service used by WoWTranslate.

Avoid using the addon to translate sensitive or private information that you would not want to send to a third-party service.

## Troubleshooting

### Translations are not working

Make sure:

1. The `WoWTranslate` folder is inside `Interface/AddOns`.
2. `wowtranslate.dll` is in the **main WoW game directory**, not the AddOns folder.
3. `dlls.txt` contains exactly:

```text
wowtranslate.dll
```

4. The WoWTranslate addon is enabled in the AddOns menu.
5. You are using a compatible WoW client.

### DLL is not loading

Check that the DLL filename is exactly:

```text
wowtranslate.dll
```

and that `dlls.txt` references the same filename.

## Contributing

Bug reports, suggestions, and contributions are welcome.

When reporting an issue, please include:

* WoW client/server version
* WoWTranslate version
* Steps to reproduce the issue
* Any error messages or screenshots
* Relevant information from the game or DLL logs

## License

See the [`LICENSE`](LICENSE) file for the terms under which this project is distributed.
