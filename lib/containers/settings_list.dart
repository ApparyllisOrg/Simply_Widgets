import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

abstract class SettingListEntry {}

class SettingsEntry extends SettingListEntry {
  final String title;
  final String hint;
  final bool Function() getValue;
  final void Function(bool) setValue;
  final EdgeInsets padding;

  // A custom child widget for settings that are not just checkboxes
  final Widget? child;

  static SettingsEntry custom({required Widget child, EdgeInsets padding = const EdgeInsets.all(20)}) {
    return SettingsEntry(title: "", hint: "", getValue: () => true, setValue: (newValue) {}, child: child, padding: padding);
  }

  SettingsEntry(
      {required this.title, required this.hint, required this.getValue, required this.setValue, this.padding = const EdgeInsets.all(20), this.child});
}

class SettingsDivider extends SettingListEntry {
  final String? title;
  final EdgeInsets padding;

  SettingsDivider({this.title, this.padding = const EdgeInsets.all(20)});
}

class SettingsList extends StatefulWidget {
  SettingsList({super.key, required this.settings});

  final List<SettingListEntry> settings;

  @override
  State<SettingsList> createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  @override
  Widget build(BuildContext context) {
    List<Widget> entries = [];

    widget.settings.forEach((entry) {
      if (entry is SettingsDivider) {
        SettingsDivider? divider = entry as SettingsDivider?;
        if (divider != null) {
          String? title = divider.title;
          if (title != null) {
            Widget dividerWidget = Padding(
                padding: divider.padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 15, color: Theme.of(context).highlightColor),
                    ),
                    Divider(),
                  ],
                ));
            entries.add(dividerWidget);
            return;
          }

          entries.add(Divider());
          return;
        }
      }

      if (entry is SettingsEntry) {
        SettingsEntry? settingsEntry = entry as SettingsEntry?;
        if (settingsEntry != null) {
          if (settingsEntry.child != null) {
            entries.add(Padding(
              child: settingsEntry.child,
              padding: settingsEntry.padding,
            ));
            return;
          }

          Widget entryWidget = Row(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settingsEntry.title,
                    style: TextStyle(fontSize: 14),
                  ).padding(bottom: 5),
                  Text(
                    settingsEntry.hint,
                    style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                  )
                ],
              )),
              Switch(
                  value: settingsEntry.getValue(),
                  activeColor: Theme.of(context).highlightColor,
                  onChanged: (bool newValue) {
                    setState(() {
                      settingsEntry.setValue(newValue);
                    });
                  })
            ],
          );
          entries.add(Padding(
            child: entryWidget,
            padding: settingsEntry.padding,
          ));
          return;
        }
      }
    });

    return Column(
      children: entries,
    );
  }
}
