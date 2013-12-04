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
      return this.layer.removeChildren();
    };

    Plan.prototype.draw = function() {
      this.renderer.render(this.scene, this.camera);
      return this.layer.batchDraw();
    };

    Plan.prototype.add = function(object) {
      this.scene.add(object.mesh);
      this.layer.add(object.polygon);
      return this.draw();
    };

    return Plan;

  })();

  $(function() {
    var $container, ASPECT, FAR, HEIGHT, NEAR, VIEW_ANGLE, WIDTH, plan;
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
      var content, line, lines, object, tokens, _i, _len, _results;
      plan.reset();
      content = event.target.value;
      lines = content.split('\n');
      _results = [];
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        tokens = line.split(',');
        if (tokens[0].trim().toLowerCase() === 'wall') {
          object = new Wall(parseInt(tokens[1].trim()), parseInt(tokens[2].trim()), parseInt(tokens[3].trim()), parseInt(tokens[4].trim()), parseInt(tokens[5].trim()), parseInt(tokens[6].trim()));
          console.log(object);
          _results.push(plan.add(object));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    });
    $container = $("#container");
    $container.append(plan.renderer.domElement);
    $('textarea#text').change();
    return plan.draw();
  });

  Wall = (function() {
    function Wall(startx, starty, endx, endy, height, width) {
      var endx2, endy2, materials, sphereMaterial, startx2, starty2;
      this.startx = startx;
      this.starty = starty;
      this.endx = endx;
      this.endy = endy;
      this.height = height;
      this.width = width;
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
      this.mesh = new THREE.Mesh(new THREE.CubeGeometry(this.length(), this.height, this.width), sphereMaterial);
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

    Wall.prototype.length = function() {
      return Math.sqrt(Math.pow(this.startx - this.endx, 2) + Math.pow(this.starty - this.endy, 2));
    };

    return Wall;

  })();

}).call(this);

/*
//@ sourceMappingURL=index.js.map
*/