import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;
import processing.core.*;
import processing.opengl.PGraphics2D;
import oscP5.*;
import netP5.*;

import KinectPV2.KJoint;
import KinectPV2.*;

OscP5 op;
DwFluid2D fluid;
PGraphics2D pg_fluid;
KinectPV2 kinect;
KJoint[] joints;
KSkeleton skeleton;
ArrayList<KSkeleton> skeletonArray;
int fakex = 512;
int fakey = 288;
PVector rpre = new PVector(0, 0);
PVector lpre = new PVector(0, 0);
float r =0;
float g =1;
float b =1;
float radin =2;
float radout =10;
public void settings()
{
  fullScreen(P2D);
}

public void setup() 
{
  op = new OscP5(this, 8000);
  kinect = new KinectPV2(this);
  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);
  kinect.init();
  DwPixelFlow context = new DwPixelFlow(this);
  context.print();
  context.printGL();

  fluid = new DwFluid2D(context, fakex, fakey, 1);

  fluid.param.dissipation_velocity = 0.9f;
  fluid.param.dissipation_density  = 0.9f;

  pg_fluid = (PGraphics2D) createGraphics(fakex, fakey, P2D);
  //blendMode(SCREEN);
  //frameRate(60);
}


public void draw() {

  background(0);
  //image(kinect.getColorImage(), 0, 0, width, height);
  fluid.addCallback_FluiData(new DwFluid2D.FluidData() 
  {
    public void update(DwFluid2D fluid) {
      if (true) {
        skeletonArray =  kinect.getSkeletonColorMap();
        for (int i = 0; i < skeletonArray.size(); i++) 
        {
          skeleton = (KSkeleton) skeletonArray.get(i);
          if (skeleton.isTracked()) 
          {
            joints = skeleton.getJoints();
            float rx = map(joints[KinectPV2.JointType_HandRight].getX(), 0, width, 0, fakex);
            float ry = fakey-map(joints[KinectPV2.JointType_HandRight].getY(), 0, height, 0, fakey);
            float lx = map(joints[KinectPV2.JointType_HandLeft].getX(), 0, width, 0, fakex);
            float ly = fakey-map(joints[KinectPV2.JointType_HandLeft].getY(), 0, height, 0, fakey);


            float rvx = (rx-rpre.x)*10;
            float rvy = (ry-rpre.y)*-10;
            float lvx = (lx-lpre.x)*10;
            float lvy = (ly-lpre.y)*-10;
            fluid.addVelocity(rx, ry, 7, rvx, rvy);
            fluid.addVelocity(lx, ly, 7, lvx, lvy);
            rpre.x = rx;  
            lpre.x = lx;
            rpre.y = ry;  
            lpre.y = ly;

            fluid.addDensity (rx, ry, radout, r, g, b, 1f);
            fluid.addDensity (lx, ly, radout, r, g, b, 1f);
            fluid.addDensity (rx, ry, radin, 1f, 1f, 1f, 1.0f);
            fluid.addDensity (lx, ly, radin, 1f, 1f, 1f, 1.0f);
          }
        }
      }
    }
  }
  );

  fluid.update();
  pg_fluid.beginDraw();
  pg_fluid.background(0);
  pg_fluid.endDraw();
  fluid.renderFluidTextures(pg_fluid, 0);
  image(pg_fluid, 0, 0, width, height);
}

void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
}

void oscEvent(OscMessage msg)
{
  if (msg.checkAddrPattern("/1/fader5")==true)
  {
    r = msg.get(0).floatValue();
  }
  if (msg.checkAddrPattern("/1/fader1")==true)
  {
    g = msg.get(0).floatValue();
  }
  if (msg.checkAddrPattern("/1/fader2")==true)
  {
    b = msg.get(0).floatValue();
  }
  if (msg.checkAddrPattern("/1/fader3")==true)
  {
    radin = map(msg.get(0).floatValue(), 0, 1, 0, 100);
  }
  if (msg.checkAddrPattern("/1/fader4")==true)
  {
    radout = map(msg.get(0).floatValue(), 0, 1, 0, 100);
  }
}