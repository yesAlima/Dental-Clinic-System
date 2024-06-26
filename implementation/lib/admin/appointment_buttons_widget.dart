import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senior/reuseable_widget.dart';

class AppointmentButtonsWidget extends StatefulWidget {
  final VoidCallback? onCreateAppointmentPressed;
  final VoidCallback? onViewAppointmentsPressed;
  final VoidCallback? onEditAppointmentPressed;
  final VoidCallback? onCancelAppointmentPressed;

  const AppointmentButtonsWidget({
    Key? key,
    this.onCreateAppointmentPressed,
    this.onViewAppointmentsPressed,
    this.onEditAppointmentPressed,
    this.onCancelAppointmentPressed,
  }) : super(key: key);

  @override
  _AppointmentButtonsWidgetState createState() =>
      _AppointmentButtonsWidgetState();
}

class _AppointmentButtonsWidgetState extends State<AppointmentButtonsWidget> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _cprControllerbook = TextEditingController();
  TextEditingController _cprController = TextEditingController();
  TextEditingController _statController = TextEditingController();
  TextEditingController _endController = TextEditingController();
  List<String> dentistName = [];
  String selectedDentistId = '';
  String selectedDentistName = '';
  int selectedDentistIndex = -1;
  @override
  void initState() {
    super.initState();
    fetchDentists().then((dentists) {
      if (mounted) {
        setState(() {
          dentistName =
              dentists.map((dentist) => dentist['name'] as String).toList();
        });
      }
    });
  }

  Future<List<Map<String, dynamic>>> fetchDentists() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> dentists = [];

    try {
      QuerySnapshot dentistSnapshot =
          await firestore.collection('dentist').get();

      for (QueryDocumentSnapshot doc in dentistSnapshot.docs) {
        String dentistId = doc.id;

        DocumentSnapshot userSnapshot =
            await firestore.collection('user').doc(dentistId).get();

        if (userSnapshot.exists &&
            userSnapshot.data() != null &&
            (userSnapshot.data() as Map<String, dynamic>)
                .containsKey('FullName')) {
          String fullName =
              (userSnapshot.data() as Map<String, dynamic>)['FullName'];

          dentists.add({'id': dentistId, 'name': 'Dr. ${fullName}'});
        }
      }
    } catch (e) {
      print('Error fetching dentists: $e');
    }
    return dentists;
  }

  Future<bool> isValidCPR(String cpr) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('CPR', isEqualTo: cpr)
        .get();

    return userSnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ButtonTheme(
            minWidth: 120,
            child: ElevatedButton(
              onPressed: () => showCreateAppointmentDialog(context),
              child: const Text(
                'Book Appointment',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ButtonTheme(
            minWidth: 120,
            child: ElevatedButton(
              onPressed: () => showSearchAppointmentDialog(context),
              child: const Text(
                'View Appointment',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ButtonTheme(
            minWidth: 120,
            child: ElevatedButton(
              onPressed: () => showEditAppointmentDialog(context),
              child: const Text(
                'Edit Appointment',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ButtonTheme(
            minWidth: 120,
            child: ElevatedButton(
              onPressed: () => showCancelAppointmentDialog(context),
              child: const Text(
                'Cancel Appointment',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showCreateAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchDentists(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: const Text('Book Appointment'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: SpinKitFadingCube(
                          color: Colors.black,
                          size: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Book Appointment'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                ),
              );
            } else {
              List<Map<String, dynamic>> dentists = snapshot.data ?? [];
              return AlertDialog(
                title: const Text('Book Appointment'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _cprControllerbook,
                        decoration:
                            InputDecoration(labelText: 'Enter Patient CPR'),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          _selectDate(context, _dateController);
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _dateController,
                                style: const TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  labelText: 'Select Appointment Date',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  enabled: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _statController,
                        onTap: () {
                          _selectTime(context,
                              isStartTime: true,
                              timeController: _statController);
                        },
                        decoration: InputDecoration(
                          labelText: 'Select Start Time (9 AM - 5 PM)',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _endController,
                        onTap: () {
                          _selectTime(context,
                              isStartTime: false,
                              timeController: _endController);
                        },
                        decoration: InputDecoration(
                          labelText: 'Select End Time (10 AM - 6 PM)',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<int>(
                        value: selectedDentistIndex >= 0
                            ? selectedDentistIndex
                            : null,
                        items: dentists.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> dentist = entry.value;
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(dentist['name']),
                          );
                        }).toList(),
                        onChanged: (int? index) {
                          setState(() {
                            if (index != null) {
                              selectedDentistIndex = index;
                              selectedDentistId = dentists[index]['id'];
                              selectedDentistName = dentists[index]['name'];
                            }
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Select Dentist',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      clearControllers();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      saveAppointment();
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  void clearControllers() {
    _cprControllerbook.clear();
    _dateController.clear();
    _statController.clear();
    _endController.clear();
  }

void saveAppointment() async {
  try {
    String uid = '';

    if (_cprControllerbook.text.isEmpty) {
      throw Exception("CPR cannot be empty");
    }

    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('CPR', isEqualTo: _cprControllerbook.text)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      uid = userSnapshot.docs.first.id;
    } else {
      throw Exception("No user found with the given CPR");
    }

    print("Start Time: ${_statController.text}");
    print("End Time: ${_endController.text}");

    if (_statController.text.isEmpty || _endController.text.isEmpty) {
      throw Exception("Start and end times cannot be empty");
    }

    int startHour = int.parse(_statController.text);
    int endHour = int.parse(_endController.text);

    if (startHour < 9 || startHour > 17 || endHour < 10 || endHour > 18) {
      throw Exception(
          "Invalid start or end time. Start time should be between 09:00 AM and 05:59 PM, and end time should be between 10:00 AM and 06:59 PM.");
    }

    if (_dateController.text.isEmpty) {
      throw Exception("Appointment date cannot be empty");
    }

    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    DateTime date;
    try {
      date = dateFormat.parseStrict(_dateController.text);
    } catch (e) {
      throw Exception("Invalid date format, should be dd/MM/yyyy");
    }

    Timestamp dateTimestamp = Timestamp.fromDate(date);

    if (selectedDentistId.isEmpty) {
      throw Exception("Please select a dentist");
    }

    // Check if the dentist is available at the specified time
    QuerySnapshot dentistAppointments = await FirebaseFirestore.instance
        .collection('appointments')
        .where('did', isEqualTo: selectedDentistId)
        .where('date', isEqualTo: dateTimestamp)
        .get();

    for (var doc in dentistAppointments.docs) {
      int existingStartHour = doc['hour'];
      int existingEndHour = doc['end'];

      if ((startHour >= existingStartHour && startHour < existingEndHour) ||
          (endHour > existingStartHour && endHour <= existingEndHour) ||
          (startHour <= existingStartHour && endHour >= existingEndHour)) {
        throw Exception("The selected dentist is not available at the specified time.");
      }
    }

    // Check if the patient already has an appointment within a week
    DateTime weekBefore = date.subtract(Duration(days: 7));
    DateTime weekAfter = date.add(Duration(days: 7));

    QuerySnapshot patientAppointments = await FirebaseFirestore.instance
        .collection('appointments')
        .where('uid', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekBefore))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(weekAfter))
        .get();

    if (patientAppointments.docs.isNotEmpty) {
      throw Exception("The patient already has an appointment within a week.");
    }

    // If all checks pass, save the appointment
    await FirebaseFirestore.instance.collection('appointments').add({
      'uid': uid,
      'did': selectedDentistId,
      'hour': startHour,
      'end': endHour,
      'date': dateTimestamp,
    });

    showMessagealert(context, 'Appointment booked successfully');
    clearControllers();
    Navigator.of(context).pop();
  } catch (e) {
    print("Error saving appointment: $e");
    showErrorDialog(context, 'Error saving appointment: ${e.toString()}');
  }
}


  Future<void> _selectTime(BuildContext context,
      {required bool isStartTime,
      required TextEditingController timeController}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? TimeOfDay(hour: 9, minute: 0)
          : TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) {
      final int selectedHour = picked.hour;
      setState(() {
        if (isStartTime) {
          timeController.text = selectedHour.toString();
        } else {
          timeController.text = selectedHour.toString();
        }
      });
    }
  }

  void _selectDate(
      BuildContext context, TextEditingController dateController) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    }
  }

  void showAppointmentInfoDialog(BuildContext context, String patientName,
      String appointmentDate, String appointmentTime, String dentistName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Information'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patient Name: $patientName'),
                Text('Appointment Date: $appointmentDate'),
                Text('Appointment Time: $appointmentTime'),
                Text('Dentist: Dr.$dentistName'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showSearchAppointmentDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Search Appointment by CPR'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _cprController,
                  decoration: InputDecoration(labelText: 'Enter Patient CPR'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String cpr = _cprController.text;
                if (cpr.isEmpty) {
                  showErrorDialog(context, 'CPR cannot be empty');
                  return;
                }

                QuerySnapshot userSnapshot = await FirebaseFirestore.instance
                    .collection('user')
                    .where('CPR', isEqualTo: cpr)
                    .get();

                if (userSnapshot.docs.isNotEmpty) {
                  String uid = userSnapshot.docs.first.id;

                  if (uid.isEmpty) {
                    showErrorDialog(context, 'User ID is invalid');
                    return;
                  }

                  DateTime now = DateTime.now();
                  int currentHour = TimeOfDay.now().hour;
                  DateTime startOfToday =
                      DateTime(now.year, now.month, now.day);

                  QuerySnapshot futureAppointmentsSnapshot =
                      await FirebaseFirestore.instance
                          .collection('appointments')
                          .where('uid', isEqualTo: uid)
                          .where('date', isGreaterThan: startOfToday)
                          .get();

                  QuerySnapshot todayAppointmentsSnapshot =
                      await FirebaseFirestore.instance
                          .collection('appointments')
                          .where('uid', isEqualTo: uid)
                          .where('date', isEqualTo: startOfToday)
                          .where('hour', isGreaterThan: currentHour)
                          .get();

                  List<QueryDocumentSnapshot> upcomingAppointments = [];
                  upcomingAppointments.addAll(futureAppointmentsSnapshot.docs);
                  upcomingAppointments.addAll(todayAppointmentsSnapshot.docs);

                  if (upcomingAppointments.isNotEmpty) {
                    var appointmentData = upcomingAppointments.first.data()
                        as Map<String, dynamic>;
                    Timestamp timestamp = appointmentData['date'];
                    DateTime dateTime = timestamp.toDate();
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(dateTime);

                    String appointmentTime = appointmentData['hour'].toString();
                    String dentistId = appointmentData['did'];

                    if (dentistId.isEmpty) {
                      showErrorDialog(context, 'Dentist ID is invalid');
                      return;
                    }

                    DocumentSnapshot dentistSnapshot = await FirebaseFirestore
                        .instance
                        .collection('user')
                        .doc(dentistId)
                        .get();

                    if (dentistSnapshot.exists) {
                      String dentistName = (dentistSnapshot.data()
                          as Map<String, dynamic>)['FullName'];

                      DocumentSnapshot patientSnapshot = await FirebaseFirestore
                          .instance
                          .collection('user')
                          .doc(uid)
                          .get();

                      if (patientSnapshot.exists) {
                        String patientName = (patientSnapshot.data()
                            as Map<String, dynamic>)['FullName'];

                        showAppointmentInfoDialog(context, patientName,
                            formattedDate, appointmentTime, dentistName);
                      } else {
                        showErrorDialog(context, 'Patient not found');
                      }
                    } else {
                      showErrorDialog(context, 'Dentist not found');
                    }
                  } else {
                    showErrorDialog(context, 'No upcoming appointments found');
                  }
                } else {
                  showErrorDialog(context, 'No user found with this CPR');
                }
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void showEditAppointmentDialog(BuildContext parentContext) {
    TextEditingController cprController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (BuildContext parentContext) {
        return AlertDialog(
          title: const Text('Edit Appointment'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: cprController,
                  decoration: InputDecoration(labelText: 'Enter Patient CPR'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(parentContext).pop();
                      },
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        String patientCPR = cprController.text;
                        if (await isValidCPR(patientCPR)) {
                          Navigator.of(context).pop();
                          showAppointmentForm(context, patientCPR);
                        } else {
                          showErrorDialog(context, 'Invalid CPR');
                        }
                      },
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showAppointmentForm(BuildContext context, String patientCPR) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('CPR', isEqualTo: patientCPR)
        .get();

    if (userSnapshot.docs.isEmpty) {
      showErrorDialog(context, 'User not found');
      return;
    }

    String userId = userSnapshot.docs.first.id;

    DateTime now = DateTime.now();
    int currentHour = TimeOfDay.now().hour;
    DateTime startOfToday = DateTime(now.year, now.month, now.day);

    QuerySnapshot futureAppointmentsSnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('uid', isEqualTo: userId)
        .where('date', isGreaterThan: startOfToday)
        .get();

    QuerySnapshot todayAppointmentsSnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('uid', isEqualTo: userId)
        .where('date', isEqualTo: startOfToday)
        .where('hour', isGreaterThan: currentHour)
        .get();

    List<QueryDocumentSnapshot> upcomingAppointments = [];
    upcomingAppointments.addAll(futureAppointmentsSnapshot.docs);
    upcomingAppointments.addAll(todayAppointmentsSnapshot.docs);

    if (upcomingAppointments.isEmpty) {
      showErrorDialog(context, 'No upcoming appointments found');
      return;
    }

    final appointment = upcomingAppointments.first;

    TextEditingController _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy')
          .format((appointment['date'] as Timestamp).toDate()),
    );
    TextEditingController _statController = TextEditingController(
      text: appointment['hour'].toString(),
    );
    TextEditingController _endController = TextEditingController(
      text: appointment['end'].toString(),
    );
    String appointmentId = appointment.id;
    String DentistId = appointment['did'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchDentists(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: const Text('Update Appointment'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: SpinKitFadingCube(
                          color: Colors.black,
                          size: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Update Appointment'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Error: ${snapshot.error}'),
                    ],
                  ),
                ),
              );
            } else {
              return AlertDialog(
                title: const Text('Update Appointment'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: TextEditingController(text: patientCPR),
                        decoration: InputDecoration(labelText: 'Patient CPR'),
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          _selectDate(context, _dateController);
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _dateController,
                                style: const TextStyle(fontSize: 16),
                                decoration: InputDecoration(
                                  labelText: 'Select Appointment Date',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  enabled: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _statController,
                        onTap: () {
                          _selectTime(context,
                              isStartTime: true,
                              timeController: _statController);
                        },
                        decoration: InputDecoration(
                          labelText: 'Select Start Time (9 AM - 5 PM)',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _endController,
                        onTap: () {
                          _selectTime(context,
                              isStartTime: false,
                              timeController: _endController);
                        },
                        decoration: InputDecoration(
                          labelText: 'Select End Time (10 AM - 6 PM)',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: fetchDentists(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            selectedDentistIndex = snapshot.data!.indexWhere(
                                (dentist) => dentist['id'] == DentistId);
                            return DropdownButtonFormField<int>(
                              value: selectedDentistIndex >= 0
                                  ? selectedDentistIndex
                                  : null,
                              items:
                                  snapshot.data!.asMap().entries.map((entry) {
                                int index = entry.key;
                                Map<String, dynamic> dentist = entry.value;
                                return DropdownMenuItem<int>(
                                  value: index,
                                  child: Text(dentist['name']),
                                );
                              }).toList(),
                              onChanged: (int? index) {
                                if (index != null) {
                                  selectedDentistIndex = index;
                                  selectedDentistId =
                                      snapshot.data![index]['id'];
                                  selectedDentistName =
                                      snapshot.data![index]['name'];
                                }
                              },
                              decoration: const InputDecoration(
                                labelText: 'Select Dentist',
                                border: OutlineInputBorder(),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      UpdateAppointments(patientCPR, appointmentId,
                          _statController, _endController, _dateController);
                    },
                    child: const Text('Update'),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

void UpdateAppointments(patientCPR, AppointmentId, _statController,
    _endController, _dateController) async {
  try {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('CPR', isEqualTo: patientCPR)
        .get();

    String uid = userSnapshot.docs.first.id;

    if (_statController.text.isEmpty || _endController.text.isEmpty) {
      throw Exception("Start and end times cannot be empty");
    }

    int startHour = int.parse(_statController.text);
    int endHour = int.parse(_endController.text);

    if (startHour < 9 || startHour > 17 || endHour < 10 || endHour > 18) {
      throw Exception(
          "Invalid start or end time. Start time should be between 09:00 AM and 05:59 PM, and end time should be between 10:00 AM and 06:59 PM.");
    }

    if (_dateController.text.isEmpty) {
      throw Exception("Appointment date cannot be empty");
    }

    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    DateTime date;
    try {
      date = dateFormat.parseStrict(_dateController.text);
    } catch (e) {
      throw Exception("Invalid date format, should be dd/MM/yyyy");
    }

    Timestamp dateTimestamp = Timestamp.fromDate(date);

    if (selectedDentistId.isEmpty) {
      throw Exception("Please select a dentist");
    }

    // Check if the dentist is available at the specified time
    QuerySnapshot dentistAppointments = await FirebaseFirestore.instance
        .collection('appointments')
        .where('did', isEqualTo: selectedDentistId)
        .where('date', isEqualTo: dateTimestamp)
        .get();

    for (var doc in dentistAppointments.docs) {
      if (doc.id == AppointmentId) continue; // Skip the current appointment being updated
      int existingStartHour = doc['hour'];
      int existingEndHour = doc['end'];

      if ((startHour >= existingStartHour && startHour < existingEndHour) ||
          (endHour > existingStartHour && endHour <= existingEndHour) ||
          (startHour <= existingStartHour && endHour >= existingEndHour)) {
        throw Exception("The selected dentist is not available at the specified time.");
      }
    }

    // Check if the patient already has an appointment within a week
    DateTime weekBefore = date.subtract(Duration(days: 7));
    DateTime weekAfter = date.add(Duration(days: 7));

    QuerySnapshot patientAppointments = await FirebaseFirestore.instance
        .collection('appointments')
        .where('uid', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekBefore))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(weekAfter))
        .get();

    for (var doc in patientAppointments.docs) {
      if (doc.id == AppointmentId) continue; // Skip the current appointment being updated
      throw Exception("The patient already has an appointment within a week.");
    }

    // If all checks pass, update the appointment
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(AppointmentId)
        .update({
      'uid': uid,
      'did': selectedDentistId,
      'hour': startHour,
      'end': endHour,
      'date': dateTimestamp,
    });

    showMessagealert(context, 'Appointment updated successfully');
    clearControllers();
    Navigator.of(context).pop();
  } catch (e) {
    print("Error Updating appointment: $e");
    showErrorDialog(context, 'Error Updating appointment: ${e.toString()}');
  }
}

  void showCancelAppointmentDialog(BuildContext context) {
    TextEditingController cprControllerCancel = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: cprControllerCancel,
                  decoration: InputDecoration(labelText: 'Enter Patient CPR'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                QuerySnapshot userSnapshot = await FirebaseFirestore.instance
                    .collection('user')
                    .where('CPR', isEqualTo: cprControllerCancel.text)
                    .get();

                if (userSnapshot.docs.isNotEmpty) {
                  String uid = userSnapshot.docs.first.id;

                  DateTime now = DateTime.now();
                  int currentHour = TimeOfDay.now().hour;
                  DateTime startOfToday =
                      DateTime(now.year, now.month, now.day);

                  QuerySnapshot futureAppointmentsSnapshot =
                      await FirebaseFirestore.instance
                          .collection('appointments')
                          .where('uid', isEqualTo: uid)
                          .where('date', isGreaterThan: startOfToday)
                          .get();

                  QuerySnapshot todayAppointmentsSnapshot =
                      await FirebaseFirestore.instance
                          .collection('appointments')
                          .where('uid', isEqualTo: uid)
                          .where('date', isEqualTo: startOfToday)
                          .where('hour', isGreaterThan: currentHour)
                          .get();

                  List<QueryDocumentSnapshot> upcomingAppointments = [];
                  upcomingAppointments.addAll(futureAppointmentsSnapshot.docs);
                  upcomingAppointments.addAll(todayAppointmentsSnapshot.docs);

                  if (upcomingAppointments.isNotEmpty) {
                    var appointmentData = upcomingAppointments.first.data()
                        as Map<String, dynamic>;
                    String appointmentId = upcomingAppointments.first.id;
                    Timestamp timestamp = appointmentData['date'];
                    DateTime dateTime = timestamp.toDate();
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(dateTime);
                    String appointmentTime = appointmentData['hour'].toString();
                    String dentistId = appointmentData['did'];

                    DocumentSnapshot dentistSnapshot = await FirebaseFirestore
                        .instance
                        .collection('user')
                        .doc(dentistId)
                        .get();

                    if (dentistSnapshot.exists) {
                      String dentistName = (dentistSnapshot.data()
                          as Map<String, dynamic>)['FullName'];

                      DocumentSnapshot patientSnapshot = await FirebaseFirestore
                          .instance
                          .collection('user')
                          .doc(uid)
                          .get();

                      if (patientSnapshot.exists) {
                        String patientName = (patientSnapshot.data()
                            as Map<String, dynamic>)['FullName'];

                        showAppointmentInfoCancelDialog(
                            context,
                            patientName,
                            formattedDate,
                            appointmentTime,
                            dentistName,
                            appointmentId);
                      }
                    }
                  } else {
                    showErrorDialog(context, 'No upcoming appointments found');
                  }
                } else {
                  showErrorDialog(context, 'User not found');
                }
              },
              child: const Text('Next'),
            ),
          ],
        );
      },
    );
  }

  showAppointmentInfoCancelDialog(
      BuildContext context,
      String patientName,
      String formattedDate,
      String appointmentTime,
      String dentistName,
      String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Information'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patient Name: $patientName'),
                Text('Appointment Date: $formattedDate'),
                Text('Appointment Time: $appointmentTime'),
                Text('Dentist:Dr. $dentistName'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('appointments')
                    .doc(appointmentId)
                    .delete();

                Navigator.of(context).pop();
                showMessagealert(context, 'Appointment canceled successfully');
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
