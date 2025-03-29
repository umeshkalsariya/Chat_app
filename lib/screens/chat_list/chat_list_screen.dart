import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screens/chat_list/chat_list_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final ChatListController chatListController = Get.put(ChatListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GetBuilder<ChatListController>(
          id: "chatList",
          builder: (controller) {
            return StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection("users").snapshots(),
                builder: (context, snapshot) {
                  return Column(
                    children: [
                      SizedBox(height: Get.height * 0.03),
                      Obx(
                        () => Expanded(
                          child: chatListController.loader.value
                              ? const Center(child: CircularProgressIndicator())
                              : controller.loader.value == false &&
                                      (snapshot.data?.docs ?? []).isEmpty
                                  ? const Text("NO DATA FOUND")
                                  : ListView.separated(
                                      itemCount:
                                          snapshot.data?.docs.length ?? 0,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 5),
                                      itemBuilder: (context, index) => InkWell(
                                        onTap: () {
                                          chatListController
                                              .update(["chatList"]);
                                          controller.gotoChatScreen(
                                              context,
                                              snapshot.data?.docs[index]
                                                      ["uid"] ??
                                                  "",
                                              snapshot.data?.docs[index]
                                                      ["name"] ??
                                                  "",
                                              snapshot.data?.docs[index]
                                                      ["photoUrl"] ??
                                                  "");
                                        },
                                        child: Container(
                                          height: 54,
                                          width: Get.width,
                                          decoration: BoxDecoration(
                                              color: controller
                                                          .lastMsgData[index] !=
                                                      null
                                                  ? (controller.lastMsgData[
                                                                      index][
                                                                  "lastMessageRead"] ==
                                                              false &&
                                                          controller.lastMsgData[
                                                                      index][
                                                                  "lastMessageSender"] !=
                                                              controller.uid)
                                                      ? Colors.blue
                                                          .withOpacity(0.1)
                                                      : Colors.white
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 34,
                                                width: 34,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                                child: CachedNetworkImage(
                                                    imageUrl: snapshot.data
                                                                ?.docs[index]
                                                            ['photoUrl'] ??
                                                        "",
                                                    fit: BoxFit.cover,
                                                    progressIndicatorBuilder:
                                                        (context, url,
                                                                progress) =>
                                                            const Icon(
                                                                Icons.error),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            const Icon(
                                                                Icons.error)),
                                              ),
                                              const SizedBox(width: 15),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Spacer(),
                                                  Text(
                                                    snapshot.data?.docs[index]
                                                            ["name"] ??
                                                        "",
                                                    style: const TextStyle(
                                                      color: Colors.yellow,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  SizedBox(
                                                    width: Get.width - 149,
                                                    child: Text(
                                                      controller.lastMsgData[
                                                                  index] !=
                                                              null
                                                          ? controller.lastMsgData[
                                                                          index]
                                                                      [
                                                                      "lastMessage"] !=
                                                                  null
                                                              ? controller
                                                                      .lastMsgData[
                                                                          index]
                                                                          [
                                                                          "lastMessage"]
                                                                      .contains(
                                                                          "https://firebasestorage")
                                                                  ? "image"
                                                                  : controller.lastMsgData[
                                                                          index]
                                                                      [
                                                                      "lastMessage"]
                                                              : ""
                                                          : "",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                ],
                                              ),
                                              const Spacer(),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  const Spacer(),
                                                  Text(
                                                      controller.lastMsgData[index] !=
                                                              null
                                                          ? controller.lastMsgData[index][
                                                                      "lastMessageTime"] !=
                                                                  null
                                                              ? controller.timeAgo(
                                                                  DateTime.fromMillisecondsSinceEpoch(
                                                                      controller.lastMsgData[index]["lastMessageTime"].seconds *
                                                                          1000))
                                                              : ""
                                                          : "",
                                                      style: TextStyle(
                                                          color: controller.lastMsgData[index] !=
                                                                  null
                                                              ? (controller.lastMsgData[index]["lastMessageRead"] ==
                                                                          false &&
                                                                      controller.lastMsgData[index]["lastMessageSender"] !=
                                                                          controller
                                                                              .uid)
                                                                  ? Colors.blue
                                                                      .withOpacity(1)
                                                                  : Colors.grey
                                                              : Colors.grey,
                                                          fontSize: 10)),
                                                  const SizedBox(height: 3),
                                                  controller.newMsgCount
                                                          .isNotEmpty
                                                      ? controller.newMsgCount[
                                                                  index] !=
                                                              0
                                                          ? Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              height: 23,
                                                              width: 23,
                                                              decoration: BoxDecoration(
                                                                  color: index ==
                                                                          0
                                                                      ? Colors
                                                                          .blue
                                                                          .withOpacity(
                                                                              1)
                                                                      : Colors
                                                                          .grey,
                                                                  shape: BoxShape
                                                                      .circle),
                                                              child: Text(
                                                                controller
                                                                    .newMsgCount[
                                                                        index]
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            )
                                                          : const SizedBox()
                                                      : const SizedBox(),
                                                  const Spacer(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                        ),
                      ),
                    ],
                  );
                });
          },
        ),
      ),
    );
  }
}
