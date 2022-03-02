/* Polyfill service v3.110.1
 * For detailed credits and licence information see https://github.com/financial-times/polyfill-service.
 *
 * Features requested: Element.prototype.after,NodeList.prototype.forEach
 *
 * - _mutation, License: CC0 (required by "Element.prototype.after")
 * - Element.prototype.after, License: CC0
 * - NodeList.prototype.forEach, License: CC0 */

(function(self, undefined) {

// _mutation
  var _mutation = (function () { // eslint-disable-line no-unused-vars

    function isNode(object) {
      // DOM, Level2
      if (typeof Node === 'function') {
        return object instanceof Node;
      }
      // Older browsers, check if it looks like a Node instance)
      return object &&
        typeof object === "object" &&
        object.nodeName &&
        object.nodeType >= 1 &&
        object.nodeType <= 12;
    }

    // http://dom.spec.whatwg.org/#mutation-method-macro
    return function mutation(nodes) {
      if (nodes.length === 1) {
        return isNode(nodes[0]) ? nodes[0] : document.createTextNode(nodes[0] + '');
      }

      var fragment = document.createDocumentFragment();
      for (var i = 0; i < nodes.length; i++) {
        fragment.appendChild(isNode(nodes[i]) ? nodes[i] : document.createTextNode(nodes[i] + ''));

      }
      return fragment;
    };
  }());

// Element.prototype.after
  /* global _mutation */
  Document.prototype.after = Element.prototype.after = function after() {
    if (this.parentNode) {
      var args = Array.prototype.slice.call(arguments),
        viableNextSibling = this.nextSibling,
        idx = viableNextSibling ? args.indexOf(viableNextSibling) : -1;

      while (idx !== -1) {
        viableNextSibling = viableNextSibling.nextSibling;
        if (!viableNextSibling) {
          break;
        }
        idx = args.indexOf(viableNextSibling);
      }

      this.parentNode.insertBefore(_mutation(arguments), viableNextSibling);
    }
  };

// Not all UAs support the Text constructor.  Polyfill on the Text constructor only where it exists
// TODO: Add a polyfill for the Text constructor, and make it a dependency of this polyfill.
  if ("Text" in self) {
    Text.prototype.after = Element.prototype.after;
  }

// NodeList.prototype.forEach
  NodeList.prototype.forEach = Array.prototype.forEach;
})
('object' === typeof window && window || 'object' === typeof self && self || 'object' === typeof global && global || {});
