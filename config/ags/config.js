const hyprland = await Service.import("hyprland");
const notifications = await Service.import("notifications");
const mpris = await Service.import("mpris");
const audio = await Service.import("audio");
const battery = await Service.import("battery");
const systemtray = await Service.import("systemtray");
const network = await Service.import("network");

const date = Variable("", {
    poll: [1000, 'date "+%b %e"'],
});

const time = Variable("", {
    poll: [1000, 'date "+%H:%M"'],
});

// widgets can be only assigned as a child in one container
// so to make a reuseable widget, make it a function
// then you can simply instantiate one by calling it

function Workspaces() {
    const activeId = hyprland.active.workspace.bind("id");
    const workspaces = hyprland.bind("workspaces").as((ws) =>
        ws
            .sort((a, b) => a.id - b.id)
            .map(({ id }) =>
                Widget.Button({
                    on_clicked: () => hyprland.messageAsync(`dispatch workspace ${id}`),
                    child: Widget.Label(`${id}`),
                    class_name: activeId.as((i) => `${i === id ? "focused" : ""}`),
                })
            )
    );

    return Widget.Box({
        class_name: "workspaces",
        vertical: true,
        children: workspaces,
    });
}

function ClientTitle() {
    return Widget.Label({
        class_name: "client-title",
        label: hyprland.active.client.bind("title").transform((s) => s.substring(0, 20)),
    });
}

function Clock() {
    return Widget.Box({
        vertical: true,
        children: [
            Widget.Label({
                class_name: "clock_date",
                label: date.bind(),
            }),
            Widget.Label({
                class_name: "clock_time",
                label: time.bind(),
            }),
        ],
    });
}

// we don't need dunst or any other notification daemon
// because the Notifications module is a notification daemon itself
function Notification() {
    const popups = notifications.bind("popups");
    return Widget.Box({
        class_name: "notification",
        visible: popups.as((p) => p.length > 0),
        children: [
            Widget.Icon({
                icon: "preferences-system-notifications-symbolic",
            }),
            Widget.Label({
                label: popups.as((p) => p[0]?.summary || ""),
            }),
        ],
    });
}

function Media() {
    const label = Utils.watch("", mpris, "player-changed", () => {
        if (mpris.players[0]) {
            const { track_artists, track_title } = mpris.players[0];
            return `${track_artists.join(", ")} - ${track_title}`;
        } else {
            return "Nothing is playing";
        }
    });

    return Widget.Button({
        class_name: "media",
        on_primary_click: () => mpris.getPlayer("")?.playPause(),
        on_scroll_up: () => mpris.getPlayer("")?.next(),
        on_scroll_down: () => mpris.getPlayer("")?.previous(),
        child: Widget.Label({ label }),
    });
}

function Volume() {
    const icons = {
        101: "overamplified",
        67: "high",
        34: "medium",
        1: "low",
        0: "muted",
    };

    function getIcon() {
        const icon = audio.speaker.is_muted
            ? 0
            : [101, 67, 34, 1, 0].find((threshold) => threshold <= audio.speaker.volume * 100);

        return `audio-volume-${icons[icon]}-symbolic`;
    }

    const icon = Widget.Icon({
        icon: Utils.watch(getIcon(), audio.speaker, getIcon),
    });

    const slider = Widget.Slider({
        hexpand: false,
        draw_value: false,
        class_name: "volume_slider",
        on_change: ({ value }) => (audio.speaker.volume = value),
        setup: (self) => {

            self.vertical = true;
            self.hook(audio.speaker, () => {
                self.value = audio.speaker.volume || 0;
            });
        },
    });

    return Widget.Box({
        class_name: "volume",
        vertical: true,
        widthRequest: 50,
        css: "min-width: 50px",
        children: [slider, icon],
    });
}

function BatteryLabel() {
    const value = battery.bind("percent").as((p) => (p > 0 ? p / 100 : 0));
    const icon = battery.bind("percent").as((p) => `battery-level-${Math.floor(p / 10) * 10}-symbolic`);

    return Widget.Box({
        class_name: "battery",
        visible: battery.bind("available"),
        children: [
            Widget.Icon({ icon }),
            Widget.LevelBar({
                widthRequest: 140,
                vpack: "center",
                value,
            }),
        ],
    });
}

function SysTray() {
    const items = systemtray.bind("items").as((items) =>
        items.map((item) =>
            Widget.Button({
                child: Widget.Icon({ icon: item.bind("icon") }),
                on_primary_click: (_, event) => item.activate(event),
                on_secondary_click: (_, event) => item.openMenu(event),
                tooltip_markup: item.bind("tooltip_markup"),
            })
        )
    );

    return Widget.Box({
        vertical: true,
        widthRequest: 50,
        children: items,
    });
}

function Wlan() {}

// layout of the bar
function Top() {
    return Widget.Box({
        vertical: true,
        spacing: 8,
        class_name: "top-box",
        children: [Workspaces()],
    });
}

function Center() {
    return Widget.Box({
        className: "test",
        vertical: true,
        spacing: 8,
        children: [Media(), Notification()],
    });
}

function Bottom() {
    return Widget.Box({
        vpack: "end",
        vertical: true,
        class_name: "bottom-box",
        spacing: 8,
        children: [Volume(), Clock(), SysTray()],
    });
}

function Bar(monitor = 0) {
    return Widget.Window({
        name: `bar-${monitor}`, // name has to be unique
        class_name: "bar",
        monitor,
        anchor: ["bottom", "left", "top"],
        exclusivity: "exclusive",
        margins: [0, 0],
        widthRequest: 50,

        child: Widget.CenterBox({
            vertical: true,
            widthRequest: 50,
            start_widget: Top(),
            end_widget: Bottom(),
        }),
    });
}

App.config({
    style: "./styles.css",
    windows: [Bar(0), Bar(1), Bar(2)],
});

Utils.monitorFile(`${App.configDir}`, function () {
    const css = `${App.configDir}/styles.css`;
    App.resetCss();
    App.applyCss(css);
});

export {};
