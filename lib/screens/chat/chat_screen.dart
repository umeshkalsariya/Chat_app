import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screens/chat/chat_controller.dart';
import 'package:chat_app/screens/chat_list/chat_list_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({
    super.key,
    required this.image,
    required this.name,
    required this.otherUserId,
    required this.userId,
    required this.roomId,
  });

  final String image;
  final String name;
  final String otherUserId;
  final String userId;
  final String roomId;

  final ChatController chatController = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    // ProfileController profileController = Get.put(ProfileController());
    ChatListController chatListController = Get.put(ChatListController());
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: WillPopScope(
            onWillPop: () async {
              chatListController.onInit();
              return true;
            },
            child: GetBuilder<ChatController>(
              id: "chat",
              builder: (controller) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      SizedBox(height: Get.height * 0.03),
                      Row(
                        children: [
                          InkWell(
                              onTap: () {
                                Get.back();
                                chatListController.onInit();
                              },
                              child: Icon(Icons.arrow_back_ios_rounded,
                                  color: Colors.blue.withOpacity(1))),
                          SizedBox(width: Get.width * 0.06),
                          Container(
                            height: Get.height * 0.05,
                            width: Get.height * 0.05,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: CachedNetworkImage(
                              imageUrl: image,
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, progress) => const Icon(Icons.error),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          SizedBox(width: Get.width * 0.04),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("chats")
                              .doc(roomId)
                              .collection(roomId)
                              .orderBy("time", descending: true)
                              .limit(100)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return const SizedBox();
                              default:
                                List<DocumentSnapshot> documents =
                                    snapshot.data!.docs;
                                return ListView.builder(
                                  controller: controller.listScrollController,
                                  reverse: true,
                                  itemCount: documents.length,
                                  itemBuilder: (context, index) {
                                    // Check for the end of the list to load more
                                    if (index >= documents.length - 1) {
                                      // Load more items
                                    }
                                    Map<String, dynamic>? data =
                                        documents[index].data()
                                            as Map<String, dynamic>?;

                                    if (data == null) {
                                      return const SizedBox();
                                    } else {
                                      if (data['read'] != true &&
                                          data['senderUid'].toString() !=
                                              userId) {
                                        controller.setReadTrue(
                                            documents[index].id, roomId);
                                      }

                                      return documents[index]["senderUid"] !=
                                              controller.uid
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: Get.height * 0.05,
                                                    width: Get.height * 0.05,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color: Colors.white,
                                                            shape: BoxShape
                                                                .circle),
                                                    clipBehavior: Clip.hardEdge,
                                                    child: SizedBox(
                                                      height: 35,
                                                      width: 35,
                                                      child: CachedNetworkImage(
                                                        imageUrl: image,
                                                        fit: BoxFit.cover,
                                                        progressIndicatorBuilder:
                                                            (context, url,
                                                                    progress) =>
                                                                const Icon(Icons
                                                                    .error),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Icon(Icons.error),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      documents[index]
                                                                  ["type"] ==
                                                              "image"
                                                          ? Container(
                                                              height: 300,
                                                              width: 200,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                              clipBehavior:
                                                                  Clip.hardEdge,
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: documents[
                                                                        index]
                                                                    ["content"],
                                                                fit:
                                                                    BoxFit.fill,
                                                                progressIndicatorBuilder: (context,
                                                                        url,
                                                                        progress) =>
                                                                    const Icon(Icons
                                                                        .error),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    const Icon(Icons
                                                                        .error),
                                                              ),
                                                            )
                                                          : IntrinsicWidth(
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            10)
                                                                    .copyWith(
                                                                        right:
                                                                            20,
                                                                        left:
                                                                            15),
                                                                constraints:
                                                                    BoxConstraints(
                                                                  maxWidth:
                                                                      Get.width /
                                                                          1.5,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .yellow
                                                                      .withOpacity(
                                                                          1),
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            0),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            25),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            25),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            25),
                                                                  ),
                                                                ),
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  documents[
                                                                          index]
                                                                      [
                                                                      "content"],
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            ),
                                                      const SizedBox(
                                                        height: 3,
                                                      ),
                                                      Text(
                                                        DateFormat("hh:mm aa").format(
                                                            DateTime.fromMillisecondsSinceEpoch(
                                                                documents[index]
                                                                            [
                                                                            "time"]
                                                                        .seconds *
                                                                    1000)),
                                                        style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 8),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ))
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      documents[index]
                                                                  ["type"] ==
                                                              "image"
                                                          ? Container(
                                                              height: 300,
                                                              width: 200,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                              clipBehavior:
                                                                  Clip.hardEdge,
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: documents[
                                                                        index]
                                                                    ["content"],
                                                                fit:
                                                                    BoxFit.fill,
                                                                progressIndicatorBuilder: (context,
                                                                        url,
                                                                        progress) =>
                                                                    const Icon(Icons
                                                                        .error),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    const Icon(Icons
                                                                        .error),
                                                              ),
                                                            )
                                                          : IntrinsicWidth(
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            10)
                                                                    .copyWith(
                                                                        right:
                                                                            15,
                                                                        left:
                                                                            20),
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color: Colors
                                                                      .blue,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            25),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            0),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            25),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            25),
                                                                  ),
                                                                ),
                                                                constraints:
                                                                    BoxConstraints(
                                                                  maxWidth:
                                                                      Get.width /
                                                                          1.5,
                                                                ),
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                  documents[
                                                                          index]
                                                                      [
                                                                      "content"],
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            ),
                                                      const SizedBox(
                                                        height: 3,
                                                      ),
                                                      Text(
                                                        DateFormat("hh:mm aa").format(
                                                            DateTime.fromMillisecondsSinceEpoch(
                                                                documents[index]
                                                                            [
                                                                            "time"]
                                                                        .seconds *
                                                                    1000)),
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 8,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Container(
                                                    height: Get.height * 0.05,
                                                    width: Get.height * 0.05,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color: Colors.white,
                                                            shape: BoxShape
                                                                .circle),
                                                    clipBehavior: Clip.hardEdge,
                                                    child: SizedBox(
                                                      height: 35,
                                                      width: 35,
                                                      child: CachedNetworkImage(
                                                        imageUrl: "",
                                                        fit: BoxFit.cover,
                                                        progressIndicatorBuilder:
                                                            (context, url,
                                                                    progress) =>
                                                                const Icon(Icons
                                                                    .error),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Icon(Icons.error),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                    }
                                  },
                                );
                            }
                          },
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            height: 50,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(100)),
                            child: GetBuilder<ChatController>(
                                id: "pic",
                                builder: (controller) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: controller.msgController,
                                          cursorColor: Colors.grey,
                                          style: const TextStyle(color: Colors.black),
                                          decoration: const InputDecoration(
                                              hintText: "Message...",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16),
                                              border: InputBorder.none),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (controller
                                              .msgController.text.isNotEmpty) {
                                            controller.sendMessage(
                                                roomId, otherUserId);
                                          }
                                        },
                                        child: const Icon(Icons.send),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                          SizedBox(height: Get.height * 0.01),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ));
  }
}
