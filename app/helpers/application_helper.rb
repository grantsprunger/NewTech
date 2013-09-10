module ApplicationHelper
  def google_analytics_js
    '(function(i,s,o,g,r,a,m){i[\'GoogleAnalyticsObject\']=r;i[r]=i[r]||function(){ (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o), m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m) })(window,document,\'script\',\'//www.google-analytics.com/analytics.js\',\'ga\'); ga(\'create\', \'UA-40057202-1\', \'bdnt.org\'); ga(\'send\', \'pageview\');'
  end

  def absolute_url(url)
    url.match(/http?[\S]:\/\//) ? url : "http://"+url
  end
end
