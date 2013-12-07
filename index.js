(function() {
  var Plan, Wall;

  Plan = (function() {
    var ASPECT, FAR, HEIGHT, NEAR, VIEW_ANGLE, WIDTH;

    WIDTH = 400;

    HEIGHT = 300;

    VIEW_ANGLE = 45;

    ASPECT = WIDTH / HEIGHT;

    NEAR = 0.1;

    FAR = 10000;

    function Plan() {
      this.camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR);
      this.camera.rotation.x = -0.7;
      this.camera.position.z = 600;
      this.camera.position.y = 600;
      this.renderer = new THREE.WebGLRenderer();
      this.renderer.setSize(WIDTH, HEIGHT);
      this.scene = new THREE.Scene();
      this.scene.add(this.camera);
      this.pointLight = new THREE.AmbientLight(0xEEEEEE);
      this.pointLight.position.x = 10;
      this.pointLight.position.y = 50;
      this.pointLight.position.z = 130;
      this.scene.add(this.pointLight);
      this.stage = new Kinetic.Stage({
        container: floorplan,
        width: WIDTH,
        height: HEIGHT,
        scale: {
          x: 1,
          y: -1
        },
        offset: {
          x: -50,
          y: 250
        }
      });
      this.layer = new Kinetic.Layer;
      this.stage.add(this.layer);
    }

    Plan.prototype.reset = function() {
      var child, children, _i, _len, _results;
      this.layer.removeChildren();
      children = this.scene.children.slice(0);
      _results = [];
      for (_i = 0, _len = children.length; _i < _len; _i++) {
        child = children[_i];
        if (child && child.name === "block") {
          _results.push(this.scene.remove(child));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Plan.prototype.draw = function() {
      this.renderer.render(this.scene, this.camera);
      return this.layer.batchDraw();
    };

    Plan.prototype.add = function(object) {
      object.mesh.name = "block";
      this.scene.add(object.mesh);
      this.layer.add(object.polygon);
      return this.draw();
    };

    Plan.prototype.fitToScreen = function() {
      var child, point, scaleX, scaleY, xMax, xMin, yMax, yMin, _i, _j, _len, _len1, _ref, _ref1;
      xMin = 0;
      xMax = 0;
      yMin = 0;
      yMax = 0;
      _ref = this.layer.children;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        _ref1 = child.getPoints();
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          point = _ref1[_j];
          if (xMin > point.x) {
            xMin = point.x;
          }
          if (xMax < point.x) {
            xMax = point.x;
          }
          if (yMin > point.y) {
            yMin = point.y;
          }
          if (yMax < point.y) {
            yMax = point.y;
          }
        }
      }
      scaleY = Math.abs(HEIGHT / (yMax - yMin));
      scaleX = Math.abs(WIDTH / (xMax - xMin));
      this.stage.setScaleY(-Math.min(scaleX, scaleY));
      this.stage.setScaleX(Math.min(scaleX, scaleY));
      this.stage.setOffsetY(yMax);
      return this.draw();
    };

    return Plan;

  })();

  $(function() {
    var $container, ASPECT, FAR, HEIGHT, NEAR, VIEW_ANGLE, WIDTH, generateTexture, plan;
    generateTexture = function() {
      var canvas, centerX, centerY, context, radius, size;
      size = 256;
      canvas = document.createElement("canvas");
      canvas.width = size;
      canvas.height = size;
      context = canvas.getContext("2d");
      context.fillStyle = "rgba( 255, 204, 102, 1 )";
      context.fillRect(0, 0, size, size);
      centerX = size / 2;
      centerY = size / 2;
      radius = size / 4;
      context.beginPath();
      context.arc(centerX, centerY, radius, 0, 2 * Math.PI, false);
      context.fillStyle = "rgba( 51, 102, 153, 1 )";
      context.fill();
      return canvas;
    };
    WIDTH = 400;
    HEIGHT = 300;
    VIEW_ANGLE = 45;
    ASPECT = WIDTH / HEIGHT;
    NEAR = 0.1;
    FAR = 10000;
    plan = new Plan();
    $('body').keypress(function(event) {
      switch (event.charCode) {
        case 119:
          plan.camera.position.z -= 10;
          break;
        case 97:
          plan.camera.position.x += 10;
          break;
        case 115:
          plan.camera.position.z += 10;
          break;
        case 100:
          plan.camera.position.x -= 10;
      }
      return plan.renderer.render(plan.scene, plan.camera);
    });
    $('#text').change(function(event) {
      var content, line, lines, object, tokens, _i, _len;
      plan.reset();
      content = event.target.value;
      lines = content.split('\n');
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        tokens = line.split(',');
        if (tokens[0].trim().toLowerCase() === 'wall') {
          object = new Wall(parseInt(tokens[1].trim()), parseInt(tokens[2].trim()), parseInt(tokens[3].trim()), parseInt(tokens[4].trim()), parseInt(tokens[5].trim()), parseInt(tokens[6].trim()));
          plan.add(object);
        }
      }
      return plan.fitToScreen();
    });
    $container = $("#container");
    $container.append(plan.renderer.domElement);
    $('textarea#text').change();
    return plan.draw();
  });

  Wall = (function() {
    function Wall(startx, starty, endx, endy, height, width) {
      var attributes, endx2, endy2, material, materials, sphereMaterial, startx2, starty2, texture, uniforms;
      this.startx = startx;
      this.starty = starty;
      this.endx = endx;
      this.endy = endy;
      this.height = height;
      this.width = width;
      texture = new THREE.Texture(this.generateTexture());
      texture.needsUpdate = true;
      uniforms = {
        texture: {
          type: 't',
          value: texture
        }
      };
      attributes = {};
      material = new THREE.ShaderMaterial({
        attributes: attributes,
        uniforms: uniforms,
        vertexShader: document.getElementById('vertex_shader').textContent,
        fragmentShader: document.getElementById('fragment_shader').textContent
      });
      materials = [
        new THREE.MeshBasicMaterial({
          color: 0xAACC00
        }), new THREE.MeshBasicMaterial({
          color: 0xCCCC00
        }), new THREE.MeshBasicMaterial({
          color: 0xBBCC00
        }), new THREE.MeshBasicMaterial({
          color: 0xAACC00
        }), new THREE.MeshBasicMaterial({
          color: 0xCC0000
        }), new THREE.MeshBasicMaterial({
          color: 0xCCCC00
        })
      ];
      sphereMaterial = new THREE.MeshFaceMaterial(materials);
      this.mesh = new THREE.Mesh(new THREE.CubeGeometry(this.length(), this.height, this.width), material);
      this.mesh.rotation.y = Math.atan((this.endy - this.starty) / (this.endx - this.startx));
      endx2 = this.endx + this.width * Math.sin(this.mesh.rotation.y);
      endy2 = this.endy - this.width * Math.cos(this.mesh.rotation.y);
      startx2 = this.startx + this.width * Math.sin(this.mesh.rotation.y);
      starty2 = this.starty - this.width * Math.cos(this.mesh.rotation.y);
      this.mesh.position.x = (endx2 + this.startx) / 2;
      this.mesh.position.z = -(endy2 + this.starty) / 2;
      this.polygon = new Kinetic.Polygon({
        points: [this.startx, this.starty, this.endx, this.endy, endx2, endy2, startx2, starty2],
        fill: 'green',
        stroke: 'black',
        strokeWidth: 4
      });
    }

    /*
    # OUTER WALLS
    	Wall, 0, -580, 0, 240, 270, 44
    	Wall, 44, 240, 990, 240, 270, 44
           Wall, 990, -580, 990, 240, 270, 44 
           Wall, 44, -536, 990, -536, 270, 44
    # BATHROOM
    	Wall, 315, 196, 315, -60, 270, 10
    	Wall, 44, 10, 137, 10, 270, 10
    	Wall, 211, 10, 305, 10, 270, 10
    	Wall, 137, 0, 137, -60, 270, 10
    	Wall, 221, 0, 221, -60, 270, 10
    # BEDROOM
           Wall, 315, -150, 315, -536, 270, 10
    */


    Wall.prototype.generateTexture = function() {
      var canvas, centerX, centerY, context, radius, size;
      size = 256;
      canvas = document.createElement("canvas");
      canvas.width = size;
      canvas.height = size;
      context = canvas.getContext("2d");
      context.fillStyle = "rgba( 255, 204, 102, 1 )";
      context.fillRect(0, 0, size, size);
      centerX = size / 2;
      centerY = size / 2;
      radius = size / 4;
      context.beginPath();
      context.arc(centerX, centerY, radius, 0, 2 * Math.PI, false);
      context.fillStyle = "rgba( 51, 102, 153, 1 )";
      context.fill();
      return canvas;
    };

    Wall.prototype.length = function() {
      return Math.sqrt(Math.pow(this.startx - this.endx, 2) + Math.pow(this.starty - this.endy, 2));
    };

    return Wall;

  })();

}).call(this);

/*
//@ sourceMappingURL=index.js.map
*/