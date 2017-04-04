package com.example.hannahkwon.bluetooth1;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.util.Log;

import com.example.android.common.view.SlidingTabLayout;

/**
 * Created by HannahKwon on 2017-04-04.
 */

public class OpenFileActivity extends FragmentActivity implements ArrayListFragment.onFileSelectedListener {
    private static final String TAG = "OpenFileActivity";
    private static final int NUM_ITEMS = 2;

    public static String EXTRA_FILE_NAME = "file_name";

    StorageCollectionPageAdapter mStorageCollectionPageAdapter;
    ViewPager mViewPager;
    SlidingTabLayout mSlidingTabLayout;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_open_file);

        Log.d(TAG, "OpenFileActivity is getting created");

        // ViewPager and its adapters use support library
        // fragments, so use getSupportFragmentManager.
        mStorageCollectionPageAdapter = new StorageCollectionPageAdapter(getSupportFragmentManager());
        mViewPager = (ViewPager) findViewById(R.id.pager);
        mViewPager.setAdapter(mStorageCollectionPageAdapter);

        mSlidingTabLayout = (SlidingTabLayout) findViewById(R.id.sliding_tabs);
        mSlidingTabLayout.setViewPager(mViewPager);
    }

    public void onFileSelected(String fileName) {
        // The user selected the headline of an article from the HeadlinesFragment
        // Do something here to display that article
        Intent intent = new Intent();
        intent.putExtra(EXTRA_FILE_NAME, fileName);

        Log.d(TAG, "Selected file " + fileName);

        // Set result and finish this Activity
        setResult(Activity.RESULT_OK, intent);
        finish();
    }

    // Since this is an object collection, use a FragmentStatePagerAdapter,
    // and NOT a FragmentPagerAdapter.
    public class StorageCollectionPageAdapter extends FragmentPagerAdapter {
        public StorageCollectionPageAdapter(FragmentManager fm) {
            super(fm);
        }

        @Override
        public CharSequence getPageTitle(int position) {
            if(position == 0) {
                return "LOCAL DEVICE";
            }
            else {
                return "CLOUD STORAGE";
            }
        }

        @Override
        public Fragment getItem(int position) {
            return ArrayListFragment.newInstance(position);
        }

        @Override
        public int getCount() {
            return NUM_ITEMS;
        }
    }
}

