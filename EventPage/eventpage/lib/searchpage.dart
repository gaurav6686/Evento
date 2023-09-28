import 'dart:convert';
import 'package:eventpage/sizeconfig.dart';
import 'package:eventpage/values/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'event.dart';
import 'eventpage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Event>?> data;
  TextEditingController _searchController = TextEditingController();
  List<Event>? filteredEvents;

  Future<List<Event>?> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://sde-007.api.assignment.theinternetfolks.works/v1/event'),
      );
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

  void filterEvents(String searchText) async {
    if (searchText.isEmpty) {
      setState(() {
        filteredEvents = null;
      });
      return;
    }

    final List<Event>? events = await data;

    if (events == null) {
      return;
    }

    setState(() {
      filteredEvents = events.where((event) {
        final eventName = event.title.toLowerCase();
        final eventCategory = event.venueCity.toLowerCase();
        final searchLower = searchText.toLowerCase();

        return eventName.contains(searchLower) ||
            eventCategory.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 50.fh,
        elevation: 0.0,
        leading: const BackButton(
          color: Colors.black,
        ),
        title: Text(
          'Search',
          style: eventTextStyle,
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10.fh,
          ),
          Container(
            margin: EdgeInsets.only(left: 10.fh),
            height: 40.fh,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.fh),
            ),
            child: Center(
              child: TextField(
                controller: _searchController,
                // onChanged: filterEvents,
                onChanged: (text) {
                  print("Text changed: $text");
                  filterEvents(text);
                },
                enabled: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF5669FF),
                  ),
                  hintText: 'Type Event Name',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Event>?>(
              future: data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No events available.'));
                } else {
                  final eventsToShow =
                      filteredEvents ?? (snapshot.data as List<Event>);
                  return ListView.builder(
                    itemCount: eventsToShow.length,
                    itemBuilder: (context, index) {
                      final event = eventsToShow[index];
                      final eventDateTime = DateTime.parse(event.dateTime);
                      final formatter = DateFormat("E, MMM d, h:mm a");
                      final formattedDateTime = formatter.format(eventDateTime);
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.fh),
                        ),
                        elevation: 0,
                        margin: const EdgeInsets.all(12.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
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
                              Container(
                                height: 82.fh,
                                width:
                                    MediaQuery.of(context).size.width - 130.fw,
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16.fh),
                                  title: Text(
                                    formattedDateTime,
                                    style: dateTextStyle,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4.fh),
                                      Text(
                                        event.title,
                                        style: largeTextStyle,
                                      ),
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
          ),
        ],
      ),
    );
  }
}
