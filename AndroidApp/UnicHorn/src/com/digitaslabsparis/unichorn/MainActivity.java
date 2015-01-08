package com.digitaslabsparis.unichorn;

import com.digitaslabsparis.unichorn.BluetoothSPP.BluetoothConnectionListener;
import com.digitaslabsparis.unichorn.BluetoothSPP;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;

public class MainActivity extends Activity {

	public final static  String TAG = "BL";
	private final static int REQUEST_ENABLE_BT = 1;
	private int intensity = 240;
	private SeekBar inten = null;

	
	BluetoothSPP bt;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		bt = new BluetoothSPP(this);
		RelativeLayout v = (RelativeLayout) findViewById(R.id.mainLayout);
		v.setAlpha(0.1f);
		if(!bt.isBluetoothEnabled()) {
	        // Do somthing if bluetooth is disable
	    	 Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
	    	 startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
	    } else {
	        // Do something if bluetooth is already enable
	    	bt.setBluetoothConnectionListener(new BluetoothConnectionListener() {
	    	    public void onDeviceConnected(String name, String address) {
	    	        // Do something when successfully connected
	    	    	addListenerOnButton();
	    	    }

	    	    public void onDeviceDisconnected() {
	    	        // Do something when connection was disconnected
	    	    	RelativeLayout v = (RelativeLayout) findViewById(R.id.mainLayout);
	    			v.setAlpha(0.1f);
	    	    	bt.disconnect();
	            	chooseDevice();
	    	    }

	    	    public void onDeviceConnectionFailed() {
	    	        // Do something when connection failed
	    	    	RelativeLayout v = (RelativeLayout) findViewById(R.id.mainLayout);
	    			v.setAlpha(0.1f);
	    	    	bt.disconnect();
	            	chooseDevice();
	    	    }
	    	});
            bt.setupService();
	    	bt.startService(BluetoothState.DEVICE_OTHER);
        	chooseDevice();
	    }
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	
	public void onStart() {
	    super.onStart();
	    
	}
	
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(resultCode != RESULT_CANCELED){
		
			Log.d(TAG,"> "+requestCode+" - "+resultCode);
	        if (requestCode == REQUEST_ENABLE_BT) {
	            if (resultCode == RESULT_OK) {
	                bt.setupService();
	            	bt.startService(BluetoothState.DEVICE_OTHER);
	            	chooseDevice();
	            }
	        }
	        else if(requestCode == BluetoothState.REQUEST_CONNECT_DEVICE) {
	        	if(resultCode == Activity.RESULT_OK){
	        		bt.connect(data);
	            }
	        }
	        else{
	    		   
	        }
		}
    }
	
	@Override
	protected void onStop() {
	    super.onStop();  // Always call the superclass method first
	    byte[] data = new byte[1];
		data[0] = 0x00;
        bt.send(data, false);
	    bt.disconnect();
	} 
	
	private void chooseDevice(){
		Intent intent = new Intent(getApplicationContext(), DeviceList.class);
		startActivityForResult(intent, BluetoothState.REQUEST_CONNECT_DEVICE);
	}
	
	public void addListenerOnButton() {
		RelativeLayout v = (RelativeLayout) findViewById(R.id.mainLayout);
		v.setAlpha(1.0f);
		inten = (SeekBar) findViewById(R.id.intenbar);
		inten.setOnSeekBarChangeListener(new OnSeekBarChangeListener() {
			public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser){
				intensity = progress+240;
			}

			@Override
			public void onStartTrackingTouch(SeekBar arg0) {
				// TODO Auto-generated method stub
				
			}

			@Override
			public void onStopTrackingTouch(SeekBar arg0) {
				// TODO Auto-generated method stub
				
			}

		});
		
		TextView button = (TextView) findViewById(R.id.textView0);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				byte[] data = new byte[1];
				data[0] = (byte) intensity;
				Log.d(TAG,Integer.toHexString(data[0]));
                bt.send(data, false);
			}
 
		});
		
		button = (TextView) findViewById(R.id.textView1);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				byte[] data = new byte[1];
				data[0] = 0x00;
                bt.send(data, false);
			}
 
		});
		
		button = (TextView) findViewById(R.id.textView2);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				byte[] data = new byte[1];
				data[0] = 0x01;
                bt.send(data, false);
			}
 
		});
		
		button = (TextView) findViewById(R.id.textView3);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				byte[] data = new byte[1];
				data[0] = 0x02;
                bt.send(data, false);
			}
 
		});
		
		button = (TextView) findViewById(R.id.textView4);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				byte[] data = new byte[1];
				data[0] = 0x03;
                bt.send(data, false);
			}
 
		});
		
		button = (TextView) findViewById(R.id.textView5);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				byte[] data = new byte[1];
				data[0] = 0x04;
                bt.send(data, false);
			}
 
		});
		
		button = (TextView) findViewById(R.id.textView6);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				byte[] data = new byte[1];
				data[0] = 0x05;
                bt.send(data, false);
			}
 
		});
		
		button = (TextView) findViewById(R.id.textView7);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				byte[] data = new byte[1];
				data[0] = 0x06;
                bt.send(data, false);
			}
 
		});
		
		button = (TextView) findViewById(R.id.textView8);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				byte[] data = new byte[1];
				data[0] = 0x07;
                bt.send(data, false);
			}
 
		});
		
		button = (TextView) findViewById(R.id.textView9);
		button.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View arg0) {
				byte[] data = new byte[1];
				data[0] = 0x08;
                bt.send(data, false);
			}
 
		});
 
	}
}
