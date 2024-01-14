// create a singleton
import 'dart:convert';

import 'package:bugle/firebase/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/calendar/v3.dart';

class CalendarFetcher {
  static final CalendarFetcher _instance = CalendarFetcher._internal();
  factory CalendarFetcher() => _instance;
  CalendarFetcher._internal();

  void updateUserData(DocumentReference<Object?> userRef) async {
    var events = await fetchCalendars();
    if (events == null) return;
    userRef.update({'availability': events});
  }

  // A method to fetch the user's events for the next week from all their calendars and return them as a JSON string
  Future<String?> fetchCalendars() async {
    var authenticatedClient =
        await AuthManager().googleSignIn.authenticatedClient();
    if (authenticatedClient == null) return null;
    var calendarApi = CalendarApi(authenticatedClient);
    var calendars = await calendarApi.calendarList.list();
    // get all the ids of the calendars, filter out null ids
    var calendarIds = calendars.items?.map((e) => e.id).toList();
    if (calendarIds == null) return null;
    var events = await _fetchEvents(calendarApi, calendarIds);
    return events;
  }

  // A method to fetch the user's calendar events
  Future<String> _fetchEvents(
      CalendarApi calendarApi, List<String?> calendarIds) async {
    // Get the start and end of today in UTC
    var now = DateTime.now();
    var startOfDay = DateTime(now.year, now.month, now.day);
    var endOfDay = startOfDay
        .add(const Duration(days: 7))
        .subtract(const Duration(seconds: 1));
    List<Event> allEvents = [];

    // For each calendar, get the events for today
    for (var calId in calendarIds) {
      if (calId == null) continue;
      var calEvents = await calendarApi.events.list(calId,
          timeMin: startOfDay,
          timeMax: endOfDay,
          timeZone: 'America/Los_Angeles');

      for (Event event in calEvents.items as Iterable<Event>) {
        if (event.recurrence != null && event.recurrence!.isNotEmpty) {
          var instances = await calendarApi.events.instances(
              calId, event.id.toString(),
              timeMin: startOfDay,
              timeMax: endOfDay,
              timeZone: 'America/Los_Angeles');
          allEvents.addAll(instances.items as Iterable<Event>);
        } else {
          allEvents.add(event);
        }
      }
    }

    // filter out events that have a null or empty start or end time
    var events = allEvents
        .where((e) => e.start?.dateTime != null && e.end?.dateTime != null)
        .map((e) => {eventToJson(e)})
        .join("\n");

    // ignore: avoid_print
    print(events);
    return events;
  }

  // This code block defines a function named eventToJson that takes an Event object as input and returns a JSON-encoded string.
  // The function first creates an empty list of maps named attendees.
  // It then iterates over the attendees list of the input event object and adds a map containing the attendee's name and email to the attendees list.
  // Finally, the function creates a map named body containing the event's summary, start and end times, location, and attendees list.
  // The body map is then encoded to a JSON string and returned.

  String eventToJson(Event event) {
    // List<Map<String, dynamic>> attendees = [];

    // event.attendees?.forEach((attendee) {
    //   attendees.add({
    //     'name': attendee.displayName,
    //     'email': attendee.email,
    //     // 'is_friend': false,
    //     // 'importance': 'high',
    //   });
    // });

    Map<String, dynamic> body = {
      'title': event.summary,
      'start': event.start?.dateTime?.toString(),
      'end': event.end?.dateTime?.toString(),
      //'location': event.location,
      //'attendees': attendees,
    };

    return jsonEncode(body);
  }
}
