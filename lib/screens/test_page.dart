import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaport_customer/constants/colors.dart';
import 'package:instaport_customer/screens/location_picker/places_autocomplete.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int currentStep = 0;
  List<String> dropOffSteps = ['Drop Off 1']; // Initial drop-off step

  void addDropOffStep() {
    setState(() {
      dropOffSteps.add('Drop Off ${dropOffSteps.length + 1}');
    });
  }

  void deleteDropOffStep(int index) {
    setState(() {
      dropOffSteps.removeAt(index);
      if (currentStep >= dropOffSteps.length + 1) {
        currentStep = dropOffSteps.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Stepper'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: ListView.builder(
          itemCount: dropOffSteps.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.1,
                indicatorStyle: IndicatorStyle(
                  color: Colors.black,
                  padding: EdgeInsets.only(right: 10),
                  indicator: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15)),
                    child: Center(
                        child: Text(
                      "1",
                      style: GoogleFonts.poppins(color: Colors.white),
                    )),
                  ),
                ),
                endChild: _TimelineChild(title: "Text"),
              );
            } else {
              final dropStep = dropOffSteps[index - 1];
              return Dismissible(
                key: Key(dropStep),
                onDismissed: (direction) => deleteDropOffStep(index - 1),
                background: Container(
                  color: Colors.red,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                child: TimelineTile(
                  alignment: TimelineAlign.manual,
                  lineXY: 0.1,
                  indicatorStyle: const IndicatorStyle(
                      color: Colors.blue, padding: EdgeInsets.only(right: 10)),
                  endChild: _TimelineChild(title: dropStep),
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addDropOffStep,
        child: Icon(Icons.add),
      ),
    );
  }
}

class _TimelineChild extends StatelessWidget {
  final String title;

  const _TimelineChild({required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => PlacesAutoComplete(
            latitude: 0.0,
            longitude: 0.0,
            text: "",
            index: 0,
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 80,
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.08),
          border: Border.all(
            width: 2,
            color: accentColor,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                maxLines: 1,
                "Add a pickup point for the courier",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
