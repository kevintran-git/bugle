import 'package:bugle/firebase/auth_wrapper.dart';
import 'package:bugle/firebase/calendar_fetcher.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class WeekView extends StatelessWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      child: Scaffold(
        body: SafeArea(
          child: FutureBuilder(
            future: CalendarFetcher().fetchCalendars(),
            builder: (context, snapshot) {
              var data = snapshot.data;
              if (data != null) {
                return SfCalendar(
                  view: CalendarView.week,
                  dataSource: GoogleDataSource(data),
                  timeZone: "Pacific Standard Time",
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
  }
