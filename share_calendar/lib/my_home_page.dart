import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({this.title});

  @override
  State<StatefulWidget> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  // final TextEditingController urlEditController = TextEditingController();
  // final TextEditingController titleEditController = TextEditingController();
  // final TextEditingController addressEditController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var _urlKey = GlobalKey<FormFieldState>();
  var _titleKey = GlobalKey<FormFieldState>();
  var _addressKey = GlobalKey<FormFieldState>();
  var _startKey = GlobalKey<FormFieldState>();
  var _endKey = GlobalKey<FormFieldState>();

  var startDateTime = DateTime.now();
  var endDateTime = DateTime.now().add(Duration(days: 3));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                // controller: urlEditController,
                key: _urlKey,
                decoration: InputDecoration(hintText: '輸入要分享的 url'),
              ),
              TextFormField(
                // controller: titleEditController,
                key: _titleKey,
                decoration: InputDecoration(hintText: '輸入要分享的 title'),
              ),
              TextFormField(
                // controller: addressEditController,
                key: _addressKey,
                decoration: InputDecoration(hintText: '輸入要分享的 address'),
              ),
              _buildDateTimePicker(startDateTime, '活動開始時間', _startKey),
              _buildDateTimePicker(endDateTime, '活動結束時間', _endKey)
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          formKey.currentState.save();
          _sharedEvent();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildDateTimePicker(DateTime target, String title, Key key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        DateTimeField(
          key: key,
          initialValue: DateTime.now(),
          format: DateFormat("yyyy-MM-dd HH:mm"),
          onShowPicker: (context, currentValue) async {
            final date = await showDatePicker(
                context: context,
                firstDate: DateTime(1900),
                initialDate: currentValue ?? DateTime.now(),
                lastDate: DateTime(2100));
            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime:
                    TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
              );
              return DateTimeField.combine(date, time);
            } else {
              return currentValue;
            }
          },
          onChanged: (value) => startDateTime = value,
        )
      ],
    );
  }

  Future<void> _sharedEvent() async {
    final platform = const MethodChannel('sample.poumason.dev/channels');
    try {
      var result = await platform.invokeMethod('shared', {
        'url': _urlKey.currentState.value,
        'title': _titleKey.currentState.value,
        'location': _addressKey.currentState.value,
        'startDate':
            (_startKey.currentState.value.millisecondsSinceEpoch / 1000)
                .roundToDouble(),
        'endDate': (_endKey.currentState.value.millisecondsSinceEpoch / 1000)
            .roundToDouble(),
      });
      print(result);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }
}
