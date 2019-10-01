package;

import haxe.Timer;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.space.Broadphase;
import nape.space.Space;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.display.StageDisplayState;
import openfl.display.StageQuality;
import openfl.events.AccelerometerEvent;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.sensors.Accelerometer;
import openfl.text.TextField;
import openfl.text.TextFormat;

class Main extends Sprite
{
	private var currentFPS:Float;

	private var cacheCount:Int;
	private var times:Array <Float>;

    private var bitmapDatas = new Array<BitmapData>();
    private var images = new Array<Body>();

    private var space:Space;
	private var material:Material;
	private var totalObjects:Int = 0;

	private var accelX:Float;
	private var accelY:Float;

	public function new ()
    {
		super();

		if(stage != null) onAddedToStage(null);
		else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

    private function onAddedToStage(event:Event):Void
    {
		if(event != null) removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

		for(i in 0...5) bitmapDatas.push(Assets.getBitmapData("assets/openfl" + (i + 1) + ".png"));

		space = new Space(Vec2.weak(0, 3000), Broadphase.DYNAMIC_AABB_TREE);
		space.worldLinearDrag = space.worldAngularDrag = 0;

		material = new Material(1.25, 2, 2, 2, 5);

		var borderWidth:Int = 40;

		var border = new Body(BodyType.STATIC);
		border.shapes.add(new Polygon(Polygon.rect(-borderWidth, -borderWidth, stage.stageWidth + borderWidth * 2, borderWidth)));
		border.shapes.add(new Polygon(Polygon.rect(-borderWidth, 0, borderWidth, stage.stageHeight)));
		border.shapes.add(new Polygon(Polygon.rect(stage.stageWidth, 0, borderWidth, stage.stageHeight)));
		border.shapes.add(new Polygon(Polygon.rect(-borderWidth, stage.stageHeight, stage.stageWidth + borderWidth * 2, borderWidth)));
		border.space = space;

		if(Accelerometer.isSupported)
        {
            var accelerometer = new Accelerometer();
            accelerometer.addEventListener(AccelerometerEvent.UPDATE, onAcclUpdate);
        }

		cacheCount = 0;
		times = [];

		stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
    }

    private function onEnterFrame(event:Event):Void
    {
		var currentTime = Timer.stamp();
		times.push(currentTime);

		while(times[0] < currentTime - 1) times.shift();

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		cacheCount = currentCount;

		space.step(1 / currentFPS);
		space.liveBodies.foreach(updateGraphics);

		if (Accelerometer.isSupported)
			space.gravity = Vec2.weak(4000 * accelY, 4000 * accelX);
    }

	private function updateGraphics(body:Body):Void
	{
		var graphic:Sprite = body.userData.graphic;
		graphic.x = body.position.x;
		graphic.y = body.position.y;
		graphic.rotation = body.rotation * 57.3;
	}

	private function onAcclUpdate(event:AccelerometerEvent):Void
	{
		accelX = event.accelerationX;
		accelY = event.accelerationY;
	}

	private function onMouseDown(event:MouseEvent):Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	}

	private function onMouseUp(event:MouseEvent):Void
	{
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	}

	private function onMouseMove(event:Event):Void
	{
		trace("bodies: " + totalObjects);

		var radius:Float = Math.random() * 30 + 10;

		var boxGraphic:Bitmap = new Bitmap(bitmapDatas[Math.floor(Math.random()*5)]);
		boxGraphic.width = boxGraphic.height = radius;
		boxGraphic.x = -boxGraphic.width / 2;
		boxGraphic.y = -boxGraphic.height / 2;

		var container:Sprite = new Sprite();
		container.addChild(boxGraphic);
		container.cacheAsBitmap = true;
		addChild(container);

		var box = new Body(BodyType.DYNAMIC);
		box.shapes.add(new Polygon(Polygon.box(radius, radius), material));
		box.position.setxy(stage.mouseX, stage.mouseY);
		box.angularVel = Math.random() * 90;
		box.velocity = Vec2.weak(Math.random()*10, Math.random()*10);
		box.userData.graphic = container;
		box.space = space;

		totalObjects++;
	}
}