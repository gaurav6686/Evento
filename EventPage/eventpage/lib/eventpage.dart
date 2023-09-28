import 'dart:convert';
import 'package:eventpage/sizeconfig.dart';
import 'package:eventpage/values/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'event.dart';
import 'searchpage.dart';
import 'package:intl/intl.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late Future<List<Event>?> data;

  Future<List<Event>?> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://sde-007.api.assignment.theinternetfolks.works/v1/event'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> eventList = jsonData['content']['data'];
        if (eventList.isNotEmpty) {
          final eventListTyped =
              eventList.map((json) => Event.fromJson(json)).toList();
          return eventListTyped;
        } else {
          return null;
        }
      } else {
        throw Exception(
            'Failed to load data. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error while fetching data: $error');
      throw Exception('Failed to load data. $error');
    }
  }

  @override
  void initState() {
    super.initState();
    data = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Events',
          style: eventTextStyle,
        ),
        elevation: 0.0,
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const SearchPage())),
              icon: const Icon(Icons.search, color: Colors.black)),
          const Icon(
            Icons.more_vert,
            color: Colors.black,
          ),
        ],
      ),
      body: FutureBuilder<List<Event>?>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final event = snapshot.data![index];
                final eventDateTime = DateTime.parse(event.dateTime);
                final formattedDateTime =
                    DateFormat("E, MMM d, h:mm a").format(eventDateTime);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.fh),               
                  ),
                  elevation: 0,
                  margin: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.fh),
                    child: Row(
                      children: [
                        Container(
                          // margin: EdgeInsets.only(top: 20.fh),
                          width: 80.fw,
                          height: 80.fh,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.fh)),
                            image: DecorationImage(
                                image: NetworkImage(
                                  event.bannerImage,
                                ),
                                fit: BoxFit.cover),
                          ),
                        ),
                        SizedBox(
                          height: 82.fh,
                          width: MediaQuery.of(context).size.width - 130.fw,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10.fw),
                            title: Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Text(
                                formattedDateTime,
                                style: dateTextStyle,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4.fh),
                                Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Text(
                                    event.title,
                                    style: largeTextStyle,
                                  ),
                                ),
                                SizedBox(height: 4.fh),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.grey,
                                      size: 15.fh,
                                    ),
                                    SizedBox(width: 2.fw),
                                    Text(
                                      '${event.venueCity}',
                                      style: cityTextStyle,
                                    ),
                                    SizedBox(width: 4.fw),
                                    Container(
                                      width: 6.fw,
                                      height: 6.fh,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(width: 4.fw),
                                    Text(
                                      event.venueCountry,
                                      style: cityTextStyle,
                                    ),
                                  ],
                                )
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EventDetailsScreen(event: event),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    String eventDateTimeString = "2023-09-28 14:30:00";

    DateTime eventDateTime = DateTime.parse(eventDateTimeString);
    final DateFormat dateMonthYearFormat = DateFormat('MMMM d, y');
    final DateFormat dayTimeFormat = DateFormat('EEEE, h:mm a');
    SizeConfig().init(context);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(200.fh),
          child: AppBar(
            automaticallyImplyLeading: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/image 77.png',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Row(
              children: [
                Text(
                  'Event Details',
                  style:
                      TextStyle(fontSize: 24.fh, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.all(4.fh),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.fh),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: largestTextStyle,
              ),
              SizedBox(height: 20.fh),
              Row(
                children: [
                  SizedBox(
                    height: 40.fh,
                    width: 40.fw,
                    child: Image.network(
                      event.organiserIcon,
                    ),
                  ),
                  SizedBox(width: 8.fw),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.venueName,
                        style: nameTextStyle,
                      ),
                      SizedBox(
                        height: 5.fh,
                      ),
                      Text(
                        event.organiserName,
                        style: onameTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.fh),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5.fh),
                    child: Container(
                      color: Colors.grey[300],
                      height: 40.fh,
                      width: 40.fw,
                      child: const Icon(
                        Icons.calendar_month,
                        color: Color.fromARGB(255, 97, 72, 226),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.fw),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateMonthYearFormat.format(eventDateTime),
                        style: countryTextStyle,
                      ),
                      SizedBox(
                        height: 5.fh,
                      ),
                      Text(
                        dayTimeFormat.format(eventDateTime),
                        style: onameTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.fh),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5.fh),
                    child: Container(
                      color: Colors.grey[300],
                      height: 40.fh,
                      width: 40.fw,
                      child: const Icon(
                        Icons.location_on,
                        color: Color.fromARGB(255, 97, 72, 226),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.fw),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.venueCity,
                        style: countryTextStyle,
                      ),
                      SizedBox(
                        height: 5.fh,
                      ),
                      Text(
                        event.venueCountry,
                        style: onameTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.fh),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Event',
                    style: headTextStyle,
                  ),
                  SizedBox(height: 20.fh),
                  Text(
                    event.description,
                    style: paraTextStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
            left: 40.fw, right: 40.fw, bottom: 15.fh, top: 15.fh),
        child: Container(
          height: 60.fh,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Color.fromARGB(255, 255, 255, 255),
                  spreadRadius: 41,
                  blurRadius: 30,
                  offset: Offset(0, -10))
            ],
            color: Color.fromARGB(255, 107, 81, 237),
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: const Color.fromARGB(255, 107, 81, 237),
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80.fw,
                ),
                Text(
                  'Book Now',
                  style: buttonTextStyle,
                ),
                SizedBox(
                  width: 50.fw,
                ),
                Container(
                  width: 30.fw,
                  height: 30.fh,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 39, 58, 204),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20.fh,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
