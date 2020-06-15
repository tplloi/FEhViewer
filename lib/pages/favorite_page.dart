import 'package:FEhViewer/model/favorite.dart';
import 'package:FEhViewer/values/const.dart';
import 'package:FEhViewer/values/theme_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:FEhViewer/route/navigator_util.dart';
import 'package:FEhViewer/utils/icon.dart';
import 'package:FEhViewer/route/routes.dart';

class FavoriteTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FavoriteTab();
  }
}

class _FavoriteTab extends State<FavoriteTab> {
  String _title = "All Favorites";

  void _setTitle(String title) {
    setState(() {
      _title = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text(_title),
          previousPageTitle: _title,
          trailing: GestureDetector(
            onTap: () {
              debugPrint('sel icon tapped');
              // 跳转收藏夹选择页
              NavigatorUtil.jump(context, EHRoutes.selFavorie).then((result) {
                debugPrint('${result.runtimeType}');
                if (result.runtimeType == FavcatItemBean) {
                  FavcatItemBean fav = result;
                  debugPrint('${fav.title}');
                  _setTitle(fav.title);
                } else {
                  debugPrint('$result');
                }
              });
            },
            child: Icon(
              EHCupertinoIcons.menu,
            ),
          ),
        ),
        SliverSafeArea(
          top: false,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < 100) {
                  return Text(
                    "$index",
                    style: TextStyle(fontSize: 50),
                  );
                }
                return null;
              },
            ),
          ),
        )
      ],
    );
  }
}

/// 收藏夹选择页面 列表
class SelFavorite extends StatefulWidget {
  final FavcatItemBean favcatItemBean;

  SelFavorite({this.favcatItemBean});

  @override
  _SelFavorite createState() => _SelFavorite();
}

/// 收藏夹选择页面 列表
class _SelFavorite extends State<SelFavorite> {
  String _title = "收藏夹";
  Color _color;

  final List<FavcatItemBean> favItemBeans = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  /// 初始化收藏夹选择数据
  void _initData() {
    EHConst.favList.forEach((fav) {
      var name = fav['name'];
      var desc = fav['desc'];
      favItemBeans.add(FavcatItemBean(desc, ThemeColors.favColor[name]));
    });
  }

  @override
  Widget build(BuildContext context) {
    CupertinoPageScaffold sca = CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(_title),
        ),
        child: SafeArea(
          child: ListViewFavorite(favItemBeans),
        ));

    return sca;
  }
}

class ListViewFavorite extends StatelessWidget {
  List<FavcatItemBean> favItemBeans = [];

  ListViewFavorite(this.favItemBeans);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: favItemBeans.length,

      //列表项构造器
      itemBuilder: (BuildContext context, int index) {
        return FavSelItemWidget(
          favcatItemBean: favItemBeans[index],
          index: index,
        );
      },
    );
  }
}

/// 收藏夹选择单项
class FavSelItemWidget extends StatefulWidget {
  final int index;
  final FavcatItemBean favcatItemBean;

  FavSelItemWidget({this.index, this.favcatItemBean});

  @override
  _FavSelItemWidgetState createState() => _FavSelItemWidgetState();
}

class _FavSelItemWidgetState extends State<FavSelItemWidget> {
  Color _colorTap;

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      color: _colorTap,
      padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[
            // 图标
            Icon(
              EHCupertinoIcons.heart_solid,
              color: widget.favcatItemBean.color,
            ),
            Container(
              width: 8,
            ), // 占位 宽度8
            Text(
              widget?.favcatItemBean?.title ?? '',
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  CupertinoIcons.forward,
                  size: 24.0,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
          ]),
        ],
      ),
    );

    return GestureDetector(
      child: Column(
        children: <Widget>[
          container,
          _settingItemDivider(),
        ],
      ),
      // 不可见区域点击有效
      behavior: HitTestBehavior.opaque,
      onTap: () {
        debugPrint("fav tap ${widget.index}");
        // 返回 并带上参数
        NavigatorUtil.goBackWithParams(context, widget.favcatItemBean);
      },
      onTapDown: (_) => _updatePressedColor(),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _updateNormalColor();
        });
      },
      onTapCancel: () => _updateNormalColor(),
    );
  }

  void _updateNormalColor() {
    setState(() {
      _colorTap = CupertinoColors.systemBackground;
    });
  }

  void _updatePressedColor() {
    setState(() {
      _colorTap = CupertinoColors.systemGrey4;
    });
  }

  /// 设置项分隔线
  Widget _settingItemDivider() {
    return Divider(
      height: 1.0,
      indent: 48,
      color: CupertinoColors.systemGrey,
    );
  }
}
