package com.rollingticker

import android.graphics.Color
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.RollingTickerViewManagerInterface
import com.facebook.react.viewmanagers.RollingTickerViewManagerDelegate

@ReactModule(name = RollingTickerViewManager.NAME)
class RollingTickerViewManager : SimpleViewManager<RollingTickerView>(),
  RollingTickerViewManagerInterface<RollingTickerView> {
  private val mDelegate: ViewManagerDelegate<RollingTickerView>

  init {
    mDelegate = RollingTickerViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<RollingTickerView>? {
    return mDelegate
  }

  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): RollingTickerView {
    return RollingTickerView(context)
  }

  @ReactProp(name = "color")
  override fun setColor(view: RollingTickerView?, color: String?) {
    view?.setBackgroundColor(Color.parseColor(color))
  }

  companion object {
    const val NAME = "RollingTickerView"
  }
}
