import 'package:bite_box/utils/Notifications.dart';
import 'package:bite_box/utils/push_notification_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AdminOrderRequests extends StatefulWidget {
  const AdminOrderRequests({super.key});

  @override
  State<AdminOrderRequests> createState() => _AdminOrderRequestsState();
}

class _AdminOrderRequestsState extends State<AdminOrderRequests> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List _orderRequestList = [];
  bool reloading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    DefaultCacheManager().emptyCache();
  }

  Future<void> getorderrequests() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    User? user = _auth.currentUser;

    try {
      QuerySnapshot<Map<String, dynamic>> data = await _firestore
          .collection('Admin')
          .doc(user?.email)
          .collection('Order Requests')
          .orderBy('orderDate')
          .get();
      setState(() {
        _orderRequestList = data.docs;
      });
    } catch (e) {
      print('Error fetching orders data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 254, 250),
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.menu,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Notifications()),
                  );
                },
                child: Icon(
                  Icons.notifications_none,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        body: reloading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 15),
                    child: Text(
                      'Order Requests',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: getorderrequests().asStream(),
                      builder: (context, snapshot) => ListView.builder(
                        itemCount: _orderRequestList.length,
                        itemBuilder: (context, index) {
                          var item = _orderRequestList[index];
                          var orderDate =
                              (item['orderDate'] as Timestamp).toDate();
                          var formattedDate =
                              DateFormat('dd-MM-yy \'at\' h:mm a')
                                  .format(orderDate);

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            width: width * 0.9,
                            height: 240,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 0,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 70,
                                      margin: const EdgeInsets.all(10),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        color: Colors.black12,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: item['Images'] != null &&
                                              item['Images'].isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: item['Images'][0],
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            )
                                          : Icon(Icons.image_not_supported),
                                    ),
                                    Text(
                                      item['Item Name'] ?? 'No Name',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5,
                                                  bottom: 5,
                                                  right: 10,
                                                  left: 10),
                                              child: Center(
                                                child: Text(
                                                  item['Status'],
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Colors.black12,
                                  thickness: 0.4,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          border: Border.all(color: Colors.red),
                                        ),
                                        child: Center(
                                          child: FaIcon(
                                            FontAwesomeIcons.solidCircle,
                                            size: 10,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          item['quantity'].toString() + ' x',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Text(
                                          item['Item Name'] ?? 'No Name',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Colors.black12,
                                  thickness: 0.4,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Spacer(),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Text(
                                              "₹ ${item['Price'] ?? 'N/A'}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 3, right: 10),
                                            child: FaIcon(
                                              FontAwesomeIcons.chevronRight,
                                              size: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15.0, top: 8),
                                      child:
                                          Text("Paid via ${item['Paid via']}"),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, top: 15),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(color: Colors.red),
                                          color:
                                              Color.fromARGB(24, 244, 67, 54),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0,
                                              bottom: 8,
                                              right: 10,
                                              left: 10),
                                          child: Text("Reject",
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8, top: 15),
                                      child: GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            reloading = true;
                                          });
                                          await acceptorder(item);
                                          setState(() {
                                            reloading = false;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border:
                                                Border.all(color: Colors.green),
                                            color:
                                                Color.fromARGB(15, 76, 175, 79),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0,
                                                bottom: 8,
                                                right: 10,
                                                left: 10),
                                            child: Text("Accept",
                                                style: TextStyle(
                                                    color: Colors.green)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ));
  }

  Future<void> acceptorder(DocumentSnapshot item) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    try {
      await _firestore
          .collection('Admin')
          .doc(user?.email)
          .collection('Order Requests')
          .doc(item.id)
          .update({'Status': 'Accepted'});
      await _firestore
          .collection('Admin')
          .doc(user?.email)
          .collection('Orders')
          .add({
        'OrderId': item['OrderId'],
        'Images': item['Images'],
        'Item Name': item['Item Name'],
        'Item Category': item['Item Category'],
        'Price': item['Price'],
        'quantity': item['quantity'],
        'orderDate': Timestamp.now(),
        'Status': 'Accepted',
        'Item Description': item['Item Description'],
        'Type': item['Type'],
        'Address': item['Address'],
        'Paid Via': item['Paid via'],
        'Phone': item['Phone'],
        'Email': item['Email']
      });
      await _firestore
          .collection('Admin')
          .doc(user?.email)
          .collection('Order Requests')
          .doc(item.id)
          .delete();
      final userorder = await _firestore
          .collection('Users')
          .doc(item['Email'])
          .collection('orders')
          .where('OrderId', isEqualTo: item['OrderId'])
          .get();
      final fcm =
          await _firestore.collection('fcmTokens').doc(item['Email']).get();
      final token = fcm.data()!['token'];
      await PushNotificationService.sendNotificationToUser(
        token,
        context,
        item['OrderId'],
        'Order Accepted',
        'Your Order has been accepted',
      );
      await _firestore
          .collection('Users')
          .doc(item['Email'])
          .collection('orders')
          .doc(userorder.docs[0].id)
          .update({'Status': 'Accepted'});
    } catch (e) {
      print('Error accepting order: $e');
    }
  }
}
