import 'package:flutter/material.dart';
import 'package:simply_widgets/utils/style.dart';
import 'package:styled_text/styled_text.dart' as st;
import 'package:styled_widget/styled_widget.dart';

abstract class SettingListEntry {
  final bool Function()? isEnabled;

  SettingListEntry({this.isEnabled});

  Widget createWidget(BuildContext context, void Function() onChange);
}

class SettingsEntryCustom extends SettingListEntry {
  final Widget? child;

  final EdgeInsets padding;

  SettingsEntryCustom({required this.child, this.padding = const EdgeInsets.all(20), super.isEnabled});

  @override
  Widget createWidget(BuildContext context, void Function() onChange) {
    return Padding(
      child: child,
      padding: padding,
    );
  }
}

class SettingsEntryToggle extends SettingListEntry {
  final String title;
  final String? hint;
  final bool Function() getValue;
  final void Function(bool) setValue;
  final EdgeInsets padding;

  SettingsEntryToggle(
      {required this.title, this.hint, required this.getValue, required this.setValue, this.padding = const EdgeInsets.all(20), super.isEnabled});

  @override
  Widget createWidget(BuildContext context, void Function() onChange) {
    Widget textContent;

    if (hint != null) {
      String useMsg = hint!.replaceAll('\"', '&quot;');
      useMsg = useMsg.replaceAll("'", '&apos;');

      textContent = GestureDetector(
          onTap: () {
            setValue(!getValue());
            onChange();
          },
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              title,
              style: TextStyle(fontSize: 14),
            ).padding(bottom: 5),
            st.StyledText(
              text: useMsg,
              tags: styleTags(context),
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
            )
          ]));
    } else {
      textContent = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
            onTap: () {
              setValue(!getValue());
              onChange();
            },
            child: Text(
              title,
              style: TextStyle(fontSize: 14),
            ).padding(bottom: 5))
      ]);
    }

    Widget entryWidget = Row(
      children: [
        Expanded(child: textContent),
        Switch(
            value: getValue(),
            activeColor: Theme.of(context).highlightColor,
            onChanged: (bool newValue) {
              setValue(newValue);
              onChange();
            })
      ],
    );
    return Padding(
      child: entryWidget,
      padding: padding,
    );
  }
}

class SettingsDivider extends SettingListEntry {
  final String? title;
  final EdgeInsets padding;
  final IconData? prefixIcon;

  SettingsDivider({this.title, this.padding = const EdgeInsets.only(left: 20, right: 20, bottom: 0, top: 20), this.prefixIcon, super.isEnabled})
      : super();

  @override
  Widget createWidget(BuildContext context, void Function() onChange) {
    if (title != null) {
      Widget dividerWidget = Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Visibility(
                    child: Icon(
                      prefixIcon,
                      color: Theme.of(context).highlightColor,
                    ).padding(right: 10),
                    visible: prefixIcon != null),
                Expanded(
                    child: Text(
                  title!,
                  style: TextStyle(fontSize: 15, color: Theme.of(context).highlightColor),
                ))
              ]),
              Divider(),
            ],
          ));
      return dividerWidget;
    }

    return Divider();
  }
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
      if (entry.isEnabled != null) {
        if (entry.isEnabled!() == false) {
          return;
        }
      }

      entries.add(entry.createWidget(context, () {
        setState(() {});
      }));
    });

    return Column(
      children: entries,
    );
  }
}
