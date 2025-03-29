import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  File? image;

  TextEditingController msgController = TextEditingController();

  RxBool loader = false.obs;

  final ScrollController listScrollController = ScrollController();

  String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  String? roomId;

  DateTime lastMsg = DateTime.now();

  // Future<void> pickImage(roomId) async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //
  //   if (pickedFile != null) {
  //     image = File(pickedFile.path);
  //
  //     Get.defaultDialog(
  //         title: "Send Image",
  //         content:
  //         Obx(() => Stack(
  //           alignment: Alignment.center,
  //             children: [
  //               Container(
  //                   height: 300,
  //                   width: 300,
  //                   decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.circular(15)
  //                   ),
  //                   child: Image.file(File(pickedFile.path))),
  //               loader.value ? const SmallLoader() : const SizedBox(),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           InkWell(
  //             onTap: (){
  //               image = null;
  //               Get.back();
  //             },
  //             child: Container(
  //               height: 40,
  //               width: 90,
  //               alignment: Alignment.center,
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(10),
  //                 gradient: LinearGradient(
  //                   begin: Alignment.topCenter,
  //                   end: Alignment.bottomCenter,
  //                   colors: [
  //                     ColorRes.yellowDark.withOpacity(1),
  //                     ColorRes.yellowDark.withOpacity(0.5),
  //                   ],
  //                 ),
  //               ),
  //               child: const Text("Cancel",style: TextStyle(color: Colors.white,fontSize: 15)),
  //             ),
  //           ),
  //           InkWell(
  //             onTap: () async {
  //               await uploadImage(roomId);
  //               Get.back();
  //             },
  //             child: Container(
  //               height: 40,
  //               width: 90,
  //               alignment: Alignment.center,
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(10),
  //                 gradient: LinearGradient(
  //                   begin: Alignment.topCenter,
  //                   end: Alignment.bottomCenter,
  //                   colors: [
  //                     ColorRes.yellowDark.withOpacity(1),
  //                     ColorRes.yellowDark.withOpacity(0.5),
  //                   ],
  //                 ),
  //               ),
  //               child: const Text("Send",style: TextStyle(color: Colors.white,fontSize: 15),),
  //             ),
  //           )
  //         ]
  //     );
  //     print(pickedFile.path);
  //
  //     update(['create_profile']);
  //   }
  // }

  void sendMessage(String roomId, otherUid) async {
    String msg = msgController.text;
    msgController.clear();

    if (isToday(lastMsg) == false) {
      await sendAlertMsg();
    }

    await setMessage(roomId, msg, uid);
    setLastMsgInDoc(msg, roomId);

    // update(['chat']);
  }

  // Future<void> uploadImage(String roomId) async {
  //   if (image == null) return;
  //
  //   // Generate a unique file name for the image, for example using timestamp
  //
  //   loader.value = true;
  //
  //   String fileName = 'chat_images/${DateTime.now().millisecondsSinceEpoch}_${uid}_${image!.path.split('/').last}';
  //   firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.ref().child(fileName);
  //
  //   try {
  //     // Upload the file to Firebase Storage
  //     firebase_storage.TaskSnapshot snapshot = await storageRef.putFile(image!);
  //
  //     // Get the download URL
  //     String downloadUrl = await snapshot.ref.getDownloadURL();
  //
  //     // Now, send the message with the image URL
  //     await sendImageMessage(roomId, uid, downloadUrl);
  //
  //     // Clear the image
  //     image = null;
  //
  //     loader.value = false;
  //
  //   } on firebase_storage.FirebaseException catch (e) {
  //     // Handle any errors
  //     print(e);
  //     loader.value = false;
  //     // Show an error message or alert to the user
  //   }
  // }

  Future<void> sendImageMessage(
      String roomId, String senderUid, String imageUrl) async {
    final messagesRef = FirebaseFirestore.instance
        .collection("chats")
        .doc(roomId)
        .collection(roomId);

    // Set the message data with image URL
    await messagesRef.add({
      "content": imageUrl,
      "type": "image",
      "senderUid": senderUid,
      "time": DateTime.now(),
      "read": false,
    });

    // Update the last message info in the room's document
    await setLastMsgInDoc(imageUrl, roomId);
  }

  Future<void> setLastMsgInDoc(String msg, roomId) async {
    await FirebaseFirestore.instance.collection("chats").doc(roomId).update({
      "lastMessage": msg,
      "lastMessageSender": uid,
      "lastMessageTime": DateTime.now(),
      "lastMessageRead": false,
    });
  }

  Future<void> sendAlertMsg() async {
    await FirebaseFirestore.instance
        .collection("chats")
        .doc(roomId)
        .collection(roomId!)
        .doc()
        .set({
      "content": "new Day",
      "senderUid": uid,
      "type": "alert",
      "time": DateTime.now()
    });
  }

  Future<void> setMessage(String roomId, msg, userUid) async {
    await FirebaseFirestore.instance
        .collection("chats")
        .doc(roomId)
        .collection(roomId)
        .doc()
        .set({
      "content": msg,
      "type": "text",
      "senderUid": userUid,
      "time": DateTime.now(),
      "read": false
    });
    msgController.clear();
    // update(['chat']);
  }

  Future<void> setReadTrue(String docId, roomId) async {
    await FirebaseFirestore.instance
        .collection("chats")
        .doc(roomId)
        .collection(roomId)
        .doc(docId)
        .update({"read": true});
    await setReadInChatDoc(true, roomId);
  }

  Future<void> setReadInChatDoc(bool status, roomId) async {
    await FirebaseFirestore.instance
        .collection("chats")
        .doc(roomId)
        .update({"lastMessageRead": status});
  }

  bool isToday(DateTime time) {
    DateTime now = DateTime.now();

    if (now.year == time.year &&
        now.month == time.month &&
        now.day == time.day) {
      return true;
    }
    return false;
  }
}
