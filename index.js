(function() {
  var Wall;

  $(function() {
    var $container, ASPECT, FAR, HEIGHT, NEAR, VIEW_ANGLE, WIDTH, camera, layer, object, objects, pointLight, renderer, scene, stage, _i, _j, _len, _len1;
    WIDTH = 400;
    HEIGHT = 300;
    VIEW_ANGLE = 45;
    ASPECT = WIDTH / HEIGHT;
    NEAR = 0.1;
    FAR = 10000;
    camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR);
    camera.rotation.x = -0.7;
    $('body').keypress(function(event) {
      switch (event.charCode) {
        case 119:
          camera.position.z -= 10;
          break;
        case 115:
          camera.position.z += 10;
          break;
        case 97:
          camera.position.x += 10;
          break;
        case 100:
          camera.position.x -= 10;
      }
      return renderer.render(scene, camera);
    });
    $container = $("#container");
    renderer = new THREE.WebGLRenderer();
    scene = new THREE.Scene();
    scene.add(camera);
    camera.position.z = 600;
    camera.position.y = 600;
    renderer.setSize(WIDTH, HEIGHT);
    $container.append(renderer.domElement);
    objects = [];
    objects[0] = new Wall(0, 240, 270, 240, 270, 44);
    objects[1] = new Wall(0, 0, 0, 240, 270, 44);
    objects[2] = new Wall(270, 240, 270, 0, 270, 10);
    for (_i = 0, _len = objects.length; _i < _len; _i++) {
      object = objects[_i];
      scene.add(object.mesh);
    }
    pointLight = new THREE.AmbientLight(0xEEEEEE);
    pointLight.position.x = 10;
    pointLight.position.y = 50;
    pointLight.position.z = 130;
    scene.add(pointLight);
    renderer.render(scene, camera);
    stage = new Kinetic.Stage({
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
    layer = new Kinetic.Layer;
    for (_j = 0, _len1 = objects.length; _j < _len1; _j++) {
      object = objects[_j];
      layer.add(object.polygon);
    }
    return stage.add(layer);
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