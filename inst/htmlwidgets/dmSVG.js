HTMLWidgets.widget({

     name: 'dmSVG',

     type: 'output',

     initialize: function(el, width, height) {

       return {
         // TODO: add instance fields as required
       }

     },

     renderValue: function(el, x, instance) {

       // TODO: code to render the widget, e.g.
       //console.log(x.svg)
       //console.log(x.svg.x.svg)

       el.innerHTML = x.svg;

       var svg = el.getElementsByTagName("svg")[0];
       var viewbox = svg.getAttribute("viewBox");
       var viewbox_orig = viewbox.split(" ").map(Number);

       // add touch with hammer.js
       //  using code from example
       //  https://github.com/ariutta/svg-pan-zoom/blob/master/demo/mobile.html
       x.config.customEventsHandler = {
         haltEventListeners: ['touchstart', 'touchend', 'touchmove', 'touchleave', 'touchcancel'],
         init: function(options) {
           var instance = options.instance,
             initialScale = 1,
             pannedX = 0,
             pannedY = 0
           // Init Hammer
           // Listen only for pointer and touch events
           this.hammer = new Hammer(options.svgElement, {
             inputClass: Hammer.SUPPORT_POINTER_EVENTS ? Hammer.PointerEventInput : Hammer.TouchInput
           })
           // Enable pinch
           this.hammer.get('pinch').set({
             enable: true
           })
           // Handle double tap
           this.hammer.on('doubletap', function(ev) {
             instance.zoomIn()
           })
           // Handle pan
           this.hammer.on('panstart panmove', function(ev) {
             // On pan start reset panned variables
             if (ev.type === 'panstart') {
               pannedX = 0
               pannedY = 0
             }
             // Pan only the difference
             instance.panBy({
               x: ev.deltaX - pannedX,
               y: ev.deltaY - pannedY
             })
             pannedX = ev.deltaX
             pannedY = ev.deltaY
           })
           // Handle pinch
           this.hammer.on('pinchstart pinchmove', function(ev) {
             // On pinch start remember initial zoom
             if (ev.type === 'pinchstart') {
               initialScale = instance.getZoom()
               instance.zoom(initialScale * ev.scale)
             }
             instance.zoom(initialScale * ev.scale)
           })
           // Prevent moving the page on some devices when panning over SVG
           options.svgElement.addEventListener('touchmove', function(e) {
             e.preventDefault();
           });
         },
         destroy: function() {
           this.hammer.destroy();
         }
       }

       instance.zoomWidget = svgPanZoom(svg, x.config);

       // add back viewBox that svgPanZoom removes to fill the container
       //  make it an argument on the R side in case
       //  we want to disable
       if (x.options.viewBox) {
         //  if viewbox previously defined take max of prior and bounding rect
         if (viewbox) {
           viewbox_array = viewbox.split(/[\s,\,]/)
           viewbox = [
             viewbox_array[0],
             viewbox_array[1],
             Math.max(viewbox_array[2], svg.getBoundingClientRect().width),
             Math.max(viewbox_array[3], svg.getBoundingClientRect().height)
           ].join(" ")
           svg.setAttribute('viewBox', viewbox);
         } else {
           svg.setAttribute(
             'viewBox',
             ['0', '0',
               svg.getBoundingClientRect().width,
               svg.getBoundingClientRect().height
             ].join(' ')
           )
         }
       }

       // use this to sort of make our diagram responsive
       //  or at a minimum fit within the bounds set by htmlwidgets
       //  for the parent container
       function makeResponsive(el) {
         var svg = el.getElementsByTagName("svg")[0];
         if (svg) {
           if (svg.width) {
             svg.removeAttribute("width")
           };
           if (svg.height) {
             svg.removeAttribute("height")
           };
           svg.style.width = "100%";
           svg.style.height = "100%";
         }
       };

       makeResponsive(el);

       if (!x.options.viewBox) {
         instance.zoomWidget.destroy();
         instance.zoomWidget = svgPanZoom(svg, x.config);
         if(x.panZoomOpts.node_id != "") {
            var container = 'svg'
            var elem_id = '#' + x.panZoomOpts.node_id;
            var elem = $(container).find(elem_id);
            var bb = $(elem_id)[0].getBBox();
            var position = $(elem).offset();
            var parentOffset = $(container).offset();

            position.top -= parentOffset.top;
            position.left -= parentOffset.left;

            let width = $(container).width();
            let height = $(container).height();
            let originalWidth = viewbox_orig[2];
            let originalHeight = viewbox_orig[3];

            instance.zoomWidget.panBy({x: width/2 - position.left, y: height/2 - position.top});
            zoom = originalWidth/width + originalHeight/height;
            instance.zoomWidget.zoom(zoom);
         }
         if(x.panZoomOpts.nodes_to_select != "") {
            nodeStyleSelected(x.panZoomOpts.nodes_to_select)
         }
       }

       // svglite css takes precedence
       //  so style svgPanZoom more specifically
       //  so the controls show up
       function styleZoomControls(el) {
         Array.prototype.map.call(
           document.querySelectorAll("#" + el.id + " .svg-pan-zoom-control > path"),
           function(d, i) {
             d.style.fill = "black"
           }
         );
       };

       styleZoomControls(el);

       // set up a container for tasks to perform after completion
       //  one example would be add callbacks for event handling
       //  styling
       if (!(typeof x.tasks === "undefined")) {
         if ((typeof x.tasks.length === "undefined") ||
           (typeof x.tasks === "function")) {
           // handle a function not enclosed in array
           // should be able to remove once using jsonlite
           x.tasks = [x.tasks];
         }
         x.tasks.map(function(t) {
           // for each tasks call the task with el supplied as `this`
           t.call({
             el: el,
             zoomWidget: instance.zoomWidget
           });
         });
       }

       //  use expando property so we can access later
       //    somewhere saw where expando can cause memory leak in IE
       //    could also set in HTMLWidgets.widgets[x] where matches el
       el.zoomWidget = instance.zoomWidget;

     },

     resize: function(el, width, height, instance) {

       // TODO: code to re-render the widget with a new size

     }

   });
