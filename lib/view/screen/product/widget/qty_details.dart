import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/cart_model.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/product_details_model.dart'
    as pd;
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/provider/auth_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/cart_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/product_details_provider.dart';
import 'package:flutter_sixvalley_ecommerce/provider/seller_provider.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/button/custom_button.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/cart/cart_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../../../data/model/response/product_model.dart';
import '../../../basewidget/show_custom_snakbar.dart';

class CartSheetNew extends StatefulWidget {
  final pd.ProductDetailsModel product;
  final Function callback;

  CartSheetNew({@required this.product, this.callback});

  @override
  _CartSheetNewState createState() => _CartSheetNewState();
}

class _CartSheetNewState extends State<CartSheetNew> {
  route(bool isRoute, String message) async {
    if (isRoute) {
      showCustomSnackBar(message, context, isError: false);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      showCustomSnackBar(message, context);
    }
  }

  @override
  void initState() {
    Provider.of<ProductDetailsProvider>(context, listen: false).initData(
      widget.product,
      widget.product.minimumOrderQty,
      context,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          decoration: BoxDecoration(
            color: Theme.of(context).highlightColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
          ),
          child: Consumer<ProductDetailsProvider>(
            builder: (ctx, details, child) {
              int selectedIndex = 0;
              Variation _variation;
              String _variantName = (widget.product.colors != null &&
                      widget.product.colors.length != 0)
                  ? widget.product.colors[details.variantIndex].name
                  : null;
              List<String> _variationList = [];
              for (int index = 0;
                  index < widget.product.choiceOptions.length;
                  index++) {
                _variationList.add(widget.product.choiceOptions[index]
                    .options[details.variationIndex[index]]
                    .trim());
              }
              String variationType = '';
              if (_variantName != null) {
                variationType = _variantName;
                _variationList.forEach(
                    (variation) => variationType = '$variationType-$variation');
              } else {
                bool isFirst = true;
                _variationList.forEach((variation) {
                  if (isFirst) {
                    variationType = '$variationType$variation';
                    isFirst = false;
                  } else {
                    variationType = '$variationType-$variation';
                  }
                });
              }
              double price = widget.product.unitPrice;
              int _stock = widget.product.currentStock;
              variationType = variationType.replaceAll(' ', '');
              for (Variation variation in widget.product.variation) {
                if (variation.type == variationType) {
                  price = variation.price;
                  _variation = variation;
                  _stock = variation.qty;
                  break;
                }
              }
              if (details.variantIndex >= widget.product.images.length) {
                selectedIndex = details.variantIndex -
                    (widget.product.colors.length -
                        widget.product.images.length);
              } else {
                selectedIndex = details.variantIndex;
              }
              double priceWithDiscount = PriceConverter.convertWithDiscount(
                  context,
                  price,
                  widget.product.discount,
                  widget.product.discountType);
              double priceWithQuantity = priceWithDiscount * details.quantity;
              double total = 0, avg = 0;
              widget.product.reviews.forEach((review) {
                total += review.rating;
              });
              avg = total / widget.product.reviews.length;
              String ratting = widget.product.reviews != null &&
                      widget.product.reviews.length != 0
                  ? avg.toString()
                  : "0";

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product details

                  SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                  // Variant
                  (widget.product.colors != null &&
                          widget.product.colors.length > 0)
                      ? Row(
                          children: [
                            Text(
                              '${getTranslated('select_variant', context)} : ',
                              style: titilliumRegular.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_DEFAULT),
                            ),
                            SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ListView.builder(
                                  itemCount: widget.product.colors.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (ctx, index) {
                                    String colorString = '0xff' +
                                        widget.product.colors[index].code
                                            .substring(1, 7);
                                    return InkWell(
                                      onTap: () {
                                        Provider.of<ProductDetailsProvider>(
                                                context,
                                                listen: false)
                                            .setCartVariantIndex(
                                                widget.product.minimumOrderQty,
                                                index,
                                                context);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions
                                                  .PADDING_SIZE_EXTRA_SMALL),
                                          border: details.variantIndex == index
                                              ? Border.all(
                                                  width: 1,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                )
                                              : null,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                              Dimensions
                                                  .PADDING_SIZE_EXTRA_SMALL),
                                          child: Container(
                                            height: Dimensions.topSpace,
                                            width: Dimensions.topSpace,
                                            padding: EdgeInsets.all(Dimensions
                                                .PADDING_SIZE_EXTRA_SMALL),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color:
                                                  Color(int.parse(colorString)),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                  (widget.product.colors != null &&
                          widget.product.colors.length > 0)
                      ? SizedBox(height: Dimensions.PADDING_SIZE_SMALL)
                      : SizedBox(),
                  // Variation
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.product.choiceOptions.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (ctx, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${getTranslated('available', context)} ' +
                                ' ' +
                                '${widget.product.choiceOptions[index].title} : ',
                            style: titilliumRegular.copyWith(
                              fontSize: Dimensions.FONT_SIZE_DEFAULT,
                            ),
                          ),
                          SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      crossAxisSpacing: 1,
                                      mainAxisSpacing: 1,
                                      childAspectRatio: (1 / 0.4),
                                    ),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: widget.product
                                        .choiceOptions[index].options.length,
                                    itemBuilder: (ctx, i) {
                                      return InkWell(
                                        onTap: () =>
                                            Provider.of<ProductDetailsProvider>(
                                          context,
                                          listen: false,
                                        ).setCartVariationIndex(
                                          widget.product.minimumOrderQty,
                                          index,
                                          i,
                                          context,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border:
                                                details.variationIndex[index] !=
                                                        i
                                                    ? null
                                                    : Border.all(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              widget
                                                  .product
                                                  .choiceOptions[index]
                                                  .options[i]
                                                  .trim(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: titilliumRegular.copyWith(
                                                fontSize: Dimensions
                                                    .FONT_SIZE_DEFAULT,
                                                color: details.variationIndex[
                                                            index] !=
                                                        i
                                                    ? ColorResources
                                                        .getTextTitle(context)
                                                    : Theme.of(context)
                                                        .primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // ... your existing code

                          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
// Quantity
                          Row(
                            children: [
                              Text(getTranslated('quantity', context),
                                  style: robotoBold),
                              QuantityButton(
                                isIncrement: false,
                                quantity: details.quantity,
                                stock: _stock,
                                minimumOrderQuantity:
                                    widget.product.minimumOrderQty,
                                digitalProduct:
                                    widget.product.productType == "digital",
                              ),
                              Text(details.quantity.toString(),
                                  style: titilliumSemiBold),
                              QuantityButton(
                                isIncrement: true,
                                quantity: details.quantity,
                                stock: _stock,
                                minimumOrderQuantity:
                                    widget.product.minimumOrderQty,
                                digitalProduct:
                                    widget.product.productType == "digital",
                              ),
                            ],
                          ),

                          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(getTranslated('total_price', context),
                          style: robotoBold),
                      SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                      Text(
                        PriceConverter.convertPrice(context, priceWithQuantity),
                        style: titilliumBold.copyWith(
                            color: ColorResources.getPrimary(context),
                            fontSize: Dimensions.FONT_SIZE_LARGE),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                  Row(
                    children: [
                      Provider.of<CartProvider>(context).addToCartLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : Expanded(
                              child: CustomButton(
                                buttonText: getTranslated(
                                  _stock < widget.product.minimumOrderQty &&
                                          widget.product.productType ==
                                              "physical"
                                      ? 'out_of_stock'
                                      : 'add_to_cart',
                                  context,
                                ),
                                onTap: () {
                                  if (_stock >=
                                          widget.product.minimumOrderQty ||
                                      widget.product.productType == "digital") {
                                    CartModel cart = CartModel(
                                      widget.product.id,
                                      widget.product.id,
                                      widget.product.thumbnail,
                                      widget.product.name,
                                      widget.product.addedBy == 'seller'
                                          ? '${Provider.of<SellerProvider>(context, listen: false).sellerModel.seller.fName} ${Provider.of<SellerProvider>(context, listen: false).sellerModel.seller.lName}'
                                          : 'admin',
                                      price,
                                      priceWithDiscount,
                                      details.quantity,
                                      _stock,
                                      (widget.product.colors != null &&
                                              widget.product.colors.length > 0)
                                          ? widget.product.colors[0].name
                                          : '',
                                      (widget.product.colors != null &&
                                              widget.product.colors.length > 0)
                                          ? widget.product.colors[0].code
                                          : '',
                                      _variation,
                                      widget.product.discount,
                                      widget.product.discountType,
                                      widget.product.tax,
                                      widget.product.taxModel,
                                      widget.product.taxType,
                                      1,
                                      '',
                                      widget.product.userId,
                                      '',
                                      '',
                                      '',
                                      widget.product.choiceOptions,
                                      Provider.of<ProductDetailsProvider>(
                                              context,
                                              listen: false)
                                          .variationIndex,
                                      widget.product.multiplyQty == 1
                                          ? widget.product.shippingCost *
                                              details.quantity
                                          : widget.product.shippingCost ?? 0,
                                      widget.product.minimumOrderQty,
                                      widget.product.productType,
                                      widget.product.slug,
                                    );

                                    if (Provider.of<AuthProvider>(context,
                                            listen: false)
                                        .isLoggedIn()) {
                                      Provider.of<CartProvider>(context,
                                              listen: false)
                                          .addToCartAPI(
                                        cart,
                                        route,
                                        context,
                                        widget.product.choiceOptions,
                                        Provider.of<ProductDetailsProvider>(
                                                context,
                                                listen: false)
                                            .variationIndex,
                                      );
                                    } else {
                                      Provider.of<CartProvider>(context,
                                              listen: false)
                                          .addToCart(cart);
                                      Navigator.pop(context);
                                      showCustomSnackBar(
                                        getTranslated('added_to_cart', context),
                                        context,
                                        isError: false,
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                      SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),
                      Provider.of<CartProvider>(context, listen: false)
                              .addToCartLoading
                          ? SizedBox()
                          : Expanded(
                              child: CustomButton(
                                isBuy: true,
                                buttonText: getTranslated(
                                  _stock < widget.product.minimumOrderQty &&
                                          widget.product.productType ==
                                              "physical"
                                      ? 'out_of_stock'
                                      : 'buy_now',
                                  context,
                                ),
                                onTap: () {
                                  if (_stock >=
                                          widget.product.minimumOrderQty ||
                                      widget.product.productType == "digital") {
                                    CartModel cart = CartModel(
                                      widget.product.id,
                                      widget.product.id,
                                      widget.product.thumbnail,
                                      widget.product.name,
                                      widget.product.addedBy == 'seller'
                                          ? '${Provider.of<SellerProvider>(context, listen: false).sellerModel.seller.fName} ${Provider.of<SellerProvider>(context, listen: false).sellerModel.seller.lName}'
                                          : 'admin',
                                      price,
                                      priceWithDiscount,
                                      details.quantity,
                                      _stock,
                                      (widget.product.colors != null &&
                                              widget.product.colors.length > 0)
                                          ? widget.product.colors[0].name
                                          : '',
                                      (widget.product.colors != null &&
                                              widget.product.colors.length > 0)
                                          ? widget.product.colors[0].code
                                          : '',
                                      _variation,
                                      widget.product.discount,
                                      widget.product.discountType,
                                      widget.product.tax,
                                      widget.product.taxModel,
                                      widget.product.taxType,
                                      1,
                                      '',
                                      widget.product.userId,
                                      '',
                                      '',
                                      '',
                                      widget.product.choiceOptions,
                                      Provider.of<ProductDetailsProvider>(
                                              context,
                                              listen: false)
                                          .variationIndex,
                                      widget.product.multiplyQty == 1
                                          ? widget.product.shippingCost *
                                              details.quantity
                                          : widget.product.shippingCost ?? 0,
                                      widget.product.minimumOrderQty,
                                      widget.product.productType,
                                      widget.product.slug,
                                    );

                                    if (Provider.of<AuthProvider>(context,
                                            listen: false)
                                        .isLoggedIn()) {
                                      Provider.of<CartProvider>(context,
                                              listen: false)
                                          .addToCartAPI(
                                        cart,
                                        route,
                                        context,
                                        widget.product.choiceOptions,
                                        Provider.of<ProductDetailsProvider>(
                                                context,
                                                listen: false)
                                            .variationIndex,
                                      )
                                          .then((value) {
                                        if (value.response.statusCode == 200) {
                                          _navigateToNextScreen(context);
                                        }
                                      });
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: 'You are not logged in',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        textColor: Theme.of(context).cardColor,
                                        fontSize: 16.0,
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => CartScreen()));
  }
}

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final int quantity;
  final bool isCartWidget;
  final int stock;
  final int minimumOrderQuantity;
  final bool digitalProduct;

  QuantityButton({
    @required this.isIncrement,
    @required this.quantity,
    @required this.stock,
    this.isCartWidget = false,
    @required this.minimumOrderQuantity,
    @required this.digitalProduct,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (!isIncrement && quantity > 1) {
          if (quantity > minimumOrderQuantity) {
            Provider.of<ProductDetailsProvider>(context, listen: false)
                .setQuantity(quantity - 1);
          } else {
            Fluttertoast.showToast(
              msg:
                  '${getTranslated('minimum_quantity_is', context)}$minimumOrderQuantity',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } else if (isIncrement && quantity < stock || digitalProduct) {
          Provider.of<ProductDetailsProvider>(context, listen: false)
              .setQuantity(quantity + 1);
        }
      },
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 1,
            color: Theme.of(context).primaryColor,
          ),
        ),
        child: Icon(
          isIncrement ? Icons.add : Icons.remove,
          color: isIncrement
              ? quantity >= stock && !digitalProduct
                  ? ColorResources.getLowGreen(context)
                  : ColorResources.getPrimary(context)
              : quantity > 1
                  ? ColorResources.getPrimary(context)
                  : ColorResources.getTextTitle(context),
          size: isCartWidget ? 26 : 20,
        ),
      ),
    );
  }
}
