def resize_browser_if_necessary
  if page.driver.browser.manage.window.size.width != CAPYBARA_BROWSER_WIDTH ||
  page.driver.browser.manage.window.size.height != CAPYBARA_BROWSER_HEIGHT
    page.driver.browser.manage.window.resize_to(
      CAPYBARA_BROWSER_WIDTH,
      CAPYBARA_BROWSER_HEIGHT
    )
  end
end
