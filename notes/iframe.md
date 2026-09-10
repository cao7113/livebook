# iframe issue

## 如何解决

- 要配置 LIVEBOOK_IFRAME_PORT 单独启动iframe endpoint服务
- 配置url要全路径 LIVEBOOK_IFRAME_URL=https://livebook-iframe.s/iframe/v6.html

## 线索

查询源码，发现大概，本地http://启动时，会通过一个单独端口启动iframe服务；如果是从https://启动livebook，则默认会去 http://livebookusercontent.com 加载iframe信息，但我是本地解析的域名https://livebook.s，结果就被blocked by CORS policy（http://livebookusercontent.com 不认识我的本地livebook.s域名，也就无法验证）

如何解决呢？
启动livebook时貌似可通过 LIVEBOOK_IFRAME_URL 设置，难道要单独启动iframe应用吗，如何启动

```
// When running Livebook on https:// we load the iframe from another
// https:// origin. On the other hand, when running on http:// we want
// to load the iframe from http:// as well, otherwise the browser could
// block asset requests from the https:// iframe to http:// Livebook.
// However, external http:// content is not considered a secure context (3),
// which implies no access to user media. Therefore, instead of using
// http://livebookusercontent.com we use another localhost endpoint. Note that
// this endpoint has a different port than the Livebook web app, that's
// because we need separate origins, as outlined above.
//

function getIframeUrl(iframePort, iframeUrl) {
  const protocol = window.location.protocol;

  if (iframeUrl) {
    return iframeUrl.replace(/^https?:/, protocol);
  }

  return protocol === "https:"
    ? "https://livebookusercontent.com/iframe/v6.html"
    : `http://${window.location.hostname}:${iframePort}/iframe/v6.html`;
}
```


```
Access to fetch at 'https://livebook-iframe.s/' from origin 'https://livebook.s' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.
app.js:581  GET https://livebook-iframe.s/ net::ERR_FAILED 404 (Not Found)
```

## issue

通过本地域名 `https://livebook.s` 访问livebook出现下面的报错

```
Access to fetch at 'https://livebookusercontent.com/iframe/v6.html' from origin 'https://livebook.s' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.
app.js:581  GET https://livebookusercontent.com/iframe/v6.html net::ERR_FAILED 404 (Not Found)
Pde @ app.js:581
Tde @ app.js:581
loadIframe @ app.js:581
(anonymous) @ app.js:581
Promise.then
mounted @ app.js:581
__mounted @ app.js:10
```