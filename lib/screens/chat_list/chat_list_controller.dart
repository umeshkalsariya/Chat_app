import 'package:chat_app/screens/chat/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ChatListController extends GetxController {
  TextEditingController searchController = TextEditingController();

  RxBool loader = false.obs;

  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String? roomId;

  String getChatId(String uid1, String uid2) {
    if (uid1.hashCode > uid2.hashCode) {
      return '${uid1}_$uid2';
    } else {
      return '${uid2}_$uid1';
    }
  }

  List lastMsgData = [];
  List<int> newMsgCount = [];

  getFirestoreData() async {
    lastMsgData.clear();

    for (var e = 0; e < roomIds.length; e++) {
      final chatLastMsgData = await FirebaseFirestore.instance
          .collection("chats")
          .doc(roomIds[e])
          .get();
      lastMsgData.add(chatLastMsgData.data());

      if (lastMsgData[e] != null) {
        if (lastMsgData[e]["lastMessageRead"] == true ||
            lastMsgData[e]["lastMessageSender"] == uid) {
          newMsgCount[e] = 0;
        } else {
          newMsgCount[e] = await countUnreadMessagesUntilRead(roomIds[e]);
        }
      }
    }

    update(["chatList"]);
  }

  Future<int> countUnreadMessagesUntilRead(String roomId) async {
    // Reference to the messages subcollection
    CollectionReference messagesCollection = FirebaseFirestore.instance
        .collection('chats')
        .doc(roomId)
        .collection(roomId);

    // Query messages in descending order by the 'time' field
    QuerySnapshot querySnapshot =
        await messagesCollection.orderBy('time', descending: true).get();

    // Initialize unread messages count
    int unreadCount = 0;

    // Iterate over the documents
    for (var doc in querySnapshot.docs) {
      // Convert the document to a Map
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Check if the 'read' field is true or false
      if (data['read'] == false) {
        // Increment count if message is unread
        unreadCount++;
      } else {
        // Break the loop if message is read
        break;
      }
    }

    return unreadCount;
  }

  getRoomId(String otherUid) async {
    DocumentReference doc = FirebaseFirestore.instance
        .collection("chats")
        .doc(getChatId(uid.toString(), otherUid));

    await doc
        .collection(getChatId(uid.toString(), otherUid))
        .get()
        .then((value) async {
      DocumentSnapshot<Object?> i = await doc.get();
      if (i.exists == false) {
        await doc.set({
          "uidList": [uid, otherUid],
        });
      }
      if (value.docs.isNotEmpty) {
        roomId = getChatId(uid.toString(), otherUid);
      } else {
        await FirebaseFirestore.instance
            .collection("chats")
            .doc(getChatId(uid.toString(), otherUid))
            .collection(getChatId(uid.toString(), otherUid))
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            roomId = getChatId(uid.toString(), otherUid);
          } else {
            roomId = getChatId(uid.toString(), otherUid);
          }
        });
      }
    });
  }

  void gotoChatScreen(
      BuildContext context, String otherUid, name, image) async {
    await getRoomId(otherUid);

    Get.to(() => ChatScreen(
          roomId: roomId ?? "",
          otherUserId: otherUid,
          userId: uid,
          image: image,
          name: name,
        ));
  }

  List<String> roomIds = [];

  Future<int> countUnreadMessages(String roomId) async {
    // Reference to the subcollection
    CollectionReference messages = FirebaseFirestore.instance
        .collection('chats')
        .doc(roomId)
        .collection(roomId);

    // Query to find messages where 'lastMessageRead' is false
    QuerySnapshot querySnapshot =
        await messages.where('read', isEqualTo: false).get();

    // Count of documents where 'lastMessageRead' is false
    int count = querySnapshot.docs.length;

    return count;
  }

  String timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    }
    if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    }
    if (diff.inDays > 0) {
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    }
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    }
    return "just now";
  }
}
