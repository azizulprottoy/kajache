import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../../home/models/services_response_model.dart';
import '../../home/models/available_booking_response_model.dart';
import '../../reviews/models/review_model.dart';
import '../arguments/service_details_arguments.dart';
import '../model/comment_model.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/utils/translation_keys.dart';
import '../repository/service_details_repository.dart';

class ServiceDetailsController extends GetxController {
  final ServiceDetailsRepository _repository =
  Get.find<ServiceDetailsRepository>();
  late final String serviceSlug;
  bool isBooking = false;
  bool isProviderBidFlow = false;
  int minLimit = 0;
  String bookingId = '';
  bool hasBid = false;
  String? myBidId;
  int? myBidPrice;
  String? myBidEstimatedArrival;
  String? myBidMessage;
  JobPosterModel? poster;
  bool _hasInvalidArgument = false;
  final RxBool isLoading = false.obs;
  final RxBool isBidLoading = false.obs;
  final Rxn<ServiceModel> service = Rxn<ServiceModel>();

  // Comments state
  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final RxBool isCommentsLoading = false.obs;
  final RxBool isSubmittingComment = false.obs;
  final TextEditingController commentInputController = TextEditingController();

  // Reply state
  /// Id of the comment whose reply field is currently open (null = none).
  final RxnString openReplyId = RxnString();

  /// Id of the comment whose reply is being submitted (for a per-card spinner).
  final RxnString replySubmittingId = RxnString();
  final TextEditingController replyInputController = TextEditingController();

  // Reviews / ratings state
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isReviewsLoading = false.obs;

  /// Whether the reviews list is expanded (toggled by tapping the rating card).
  final RxBool showReviews = false.obs;

  /// Aggregated rating stats derived from [reviews].
  RatingSummary get ratingSummary => RatingSummary.fromReviews(reviews);

  void toggleReviews() => showReviews.toggle();

  @override
  void onClose() {
    commentInputController.dispose();
    replyInputController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ServiceDetailsArgument && args.serviceSlug.isNotEmpty) {
      serviceSlug = args.serviceSlug;
      isBooking = args.isbooking;
      isProviderBidFlow = args.isProviderBidFlow;
      minLimit = args.minLimit;
      bookingId = args.bookingId;
      hasBid = args.hasBid;
      myBidId = args.myBidId;
      myBidPrice = args.myBidPrice;
      myBidEstimatedArrival = args.myBidEstimatedArrival;
      myBidMessage = args.myBidMessage;
      poster = args.poster;

    } else {
      _hasInvalidArgument = true;
    }
  }

  @override
  void onReady() {
    super.onReady();

    if (_hasInvalidArgument) {
      Get.back();

      Get.snackbar(
        TKeys.error.tr,
        'Service ID not found',
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    fetchServiceDetails();
  }

  Future<bool> submitBid({
    required double price,
    required String estimatedArrival,
    String message = '',
  }) async {

    if (bookingId.isEmpty) {
      Get.snackbar(TKeys.error.tr, TKeys.bookingIdMissing.tr,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    isBidLoading.value = true;

    // Capture technician GPS silently before placing bid
    double? providerLat, providerLng;
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        providerLat = pos.latitude;
        providerLng = pos.longitude;
      }
    } catch (_) {}

    try {
      if (hasBid) {
        final bidId = myBidId;
        if (bidId == null || bidId.isEmpty) {
          throw Exception('Bid ID missing — cannot update bid.');
        }
        await _repository.updateBid(
          bookingId: bookingId,
          bidId: bidId,
          price: price,
          estimatedArrival: estimatedArrival,
          message: message,
        );
      } else {
        await _repository.placeBid(
          bookingId: bookingId,
          price: price,
          estimatedArrival: estimatedArrival,
          message: message,
          providerLat: providerLat,
          providerLng: providerLng,
        );
      }
      myBidPrice = price.round();
      myBidEstimatedArrival = estimatedArrival;
      myBidMessage = message;
      return true;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isClosed) {
          Get.snackbar(
            TKeys.error.tr,
            e.toString().replaceFirst('Exception: ', ''),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });
      return false;
    } finally {
      if (!isClosed) isBidLoading.value = false;
    }
  }

  Future<void> fetchServiceDetails() {
    final slug = serviceSlug;

    if (slug.isEmpty) {
      return Future.value();
    }

    isLoading.value = true;

    return _repository
        .getServiceBySlug(slug)
        .then((data) {
      service.value = data;
      if (data != null && data.id.isNotEmpty) {
        fetchComments(data.id);
        fetchReviews(data.id);
      }
    })
        .catchError((error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isClosed) {
          Get.snackbar(
            TKeys.error.tr,
            error.toString().replaceFirst('Exception: ', ''),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });
    })
        .whenComplete(() {
      if (!isClosed) {
        isLoading.value = false;
      }
    });
  }

  Future<void> fetchComments(String serviceId) async {
    isCommentsLoading.value = true;
    try {
      final result = await _repository.getCommentsByServiceId(serviceId);
      comments.assignAll(result);
    } catch (e) {
      debugPrint('[fetchComments] error: $e');
    } finally {
      if (!isClosed) isCommentsLoading.value = false;
    }
  }

  Future<void> fetchReviews(String serviceId) async {
    isReviewsLoading.value = true;
    try {
      final result = await _repository.getReviewsByServiceId(serviceId);
      reviews.assignAll(result);
    } catch (e) {
      debugPrint('[fetchReviews] error: $e');
    } finally {
      if (!isClosed) isReviewsLoading.value = false;
    }
  }

  Future<void> submitComment({String? userName, String? userPropic}) async {
    final text = commentInputController.text.trim();
    final serviceId = service.value?.id;

    if (text.isEmpty) {
      Get.snackbar(
        TKeys.warning.tr,
        TKeys.enterCommentFirst.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (serviceId == null || serviceId.isEmpty) {
      Get.snackbar(
        TKeys.error.tr,
        TKeys.serviceNotFound.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmittingComment.value = true;
    try {
      final newComment = await _repository.addComment(
        serviceId: serviceId,
        name: userName ?? Get.find<LocalStorageService>().read<String>('username') ?? 'User',
        propic: userPropic ?? Get.find<LocalStorageService>().read<String>('user_avatar'),
        comment: text,
      );
      comments.insert(0, newComment);
      commentInputController.clear();
      Get.snackbar(
        TKeys.success.tr,
        TKeys.commentPosted.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (!isClosed) isSubmittingComment.value = false;
    }
  }

  /// Open/close the reply text field for a given comment.
  void toggleReplyField(String commentId) {
    if (openReplyId.value == commentId) {
      openReplyId.value = null;
    } else {
      openReplyId.value = commentId;
      replyInputController.clear();
    }
  }

  /// Post the text in [replyInputController] as a reply to [commentId].
  Future<void> submitReply({
    required String commentId,
    String? userName,
    String? userPropic,
  }) async {
    final text = replyInputController.text.trim();

    if (text.isEmpty) {
      Get.snackbar(
        TKeys.warning.tr,
        TKeys.enterReplyFirst.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    replySubmittingId.value = commentId;
    try {
      final updated = await _repository.replyToComment(
        commentId: commentId,
        reply: text,
        name: userName,
        propic: userPropic,
      );

      final index = comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        comments[index] = updated;
      }

      replyInputController.clear();
      openReplyId.value = null;
      Get.snackbar(
        TKeys.success.tr,
        TKeys.replyPosted.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (!isClosed) replySubmittingId.value = null;
    }
  }

  /// Delete a reply, then refresh the affected comment from the response.
  Future<void> deleteReply({
    required String commentId,
    required String replyId,
  }) async {
    try {
      final updated = await _repository.deleteReply(
        commentId: commentId,
        replyId: replyId,
      );

      final index = comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        comments[index] = updated;
      }
    } catch (e) {
      Get.snackbar(
        TKeys.error.tr,
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

