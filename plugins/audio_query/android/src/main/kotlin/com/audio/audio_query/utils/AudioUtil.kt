package com.audio.audio_query.utils

import android.content.ContentResolver
import android.content.ContentUris
import android.content.IntentSender
import android.database.Cursor
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import java.io.File
import com.audio.audio_query.PluginProvider
import android.net.Uri
import android.app.Activity

class AudioUtil {
  fun queryMediaUris(
    mediaUri: Uri,
    resolver: ContentResolver,
    selection: String,
    selectionArgs: Array<String>
  ): List<Uri> {
    val urisToDelete = mutableListOf<Uri>()
    resolver.query(mediaUri, arrayOf(MediaStore.MediaColumns._ID), selection, selectionArgs, null)
      ?.use { cursor ->
        val idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
        while (cursor.moveToNext()) {
          val id = cursor.getLong(idColumn)
          val uri = ContentUris.withAppendedId(mediaUri, id)
          urisToDelete.add(uri)
        }
      }
    return urisToDelete
  }

  fun findMediaUri(
    filePath: String,
    resolver: ContentResolver,
    selection: String,
    selectionArgs: Array<String>
  ): Uri? {
    val mediaUris = arrayOf(
      MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
      MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
      MediaStore.Images.Media.EXTERNAL_CONTENT_URI
    )

    mediaUris.forEach { uri ->
      resolver.query(uri, arrayOf(MediaStore.MediaColumns._ID), selection, selectionArgs, null)
        ?.use { cursor ->
          if (cursor.moveToFirst()) {
            val id = cursor.getLong(cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID))
            return ContentUris.withAppendedId(uri, id)
          }
        }
    }
    return null
  }
}
