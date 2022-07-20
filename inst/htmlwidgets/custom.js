  function nodeStyle(idx) {
     $('svg .edge').removeClass('on');
     if ($("#" + idx).hasClass('on')) {
       $("#" + idx).removeClass('on');
     } else {
       $("#" + idx).addClass('on')
     }
     var idArr = [];
     $(".node.on").each(function() {
       idArr.push($(this).attr("id"));
     });
     if (idArr.length != 0) {
       Shiny.onInputChange("svg_elements:dm_nodes_edges", {"nodes":idArr});
     } else {
       clearInput("svg_elements");
     }
   }

   function edgeStyle(idx) {
     $('svg .node').removeClass('on');
     if ($("#" + idx).hasClass('on')) {
       $("#" + idx).removeClass('on');
     } else {
       $("#" + idx).addClass('on')
     }
     var idArr = [];
     $(".edge.on").each(function() {
       idArr.push($(this).attr("id"));
     });
     if (idArr.length != 0) {
       Shiny.onInputChange("svg_elements:dm_nodes_edges", {"edges": idArr});
     } else {
       clearInput("svg_elements");
     }
   }

   Shiny.addCustomMessageHandler("select_nodes", nodeStyleSelected);

   function nodeStyleSelected(items) {
     if(!Array.isArray(items) || !items.length) {
        $(".node.on").each(function() {
         $(this).removeClass("on");
       });
     } else {
       items.forEach(nodeStyle);
     }
   }

   Shiny.addCustomMessageHandler("select_edges", edgeStyleSelected);

   function edgeStyleSelected(items) {
     items.forEach(edgeStyle);
   }

   function clearInput(input_name) {
     Shiny.onInputChange(input_name, null);
   }

   Shiny.addCustomMessageHandler("reset_value", function(variableName) {
     Shiny.onInputChange(variableName, null);
   });
