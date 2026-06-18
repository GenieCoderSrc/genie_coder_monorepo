# 📦 Package Dependency Map

This file maps packages to the other packages that depend on them. When a package is updated, all its dependents in the list must also be version-bumped.

| Package | Dependents (Chain) |
| :--- | :--- |
| app_color_parser | None |
| app_date_picker | None |
| app_drop_down_menu | None |
| app_float_button | None |
| app_info_smart_unit | None |
| app_ritch_txt | None |
| app_sliver | None |
| app_style | None |
| app_toast | fire_storage_impl, firestore_db_impl, i_tdd, image_uploader, location_crud_service, location_reader |
| bottom_navigation | None |
| builder_state | None |
| dart_data_type_parser | fire_storage_impl, firestore_db_impl, image_uploader, language_translator, location_crud_service, location_reader |
| data_parser | None |
| date_time_converter | None |
| exception_type | i_tdd, image_uploader, location_crud_service, location_reader |
| fire_base_real_time_db | None |
| fire_storage_impl | image_uploader |
| firestore_db_impl | location_crud_service, location_reader |
| geo_lat_lon | location_crud_service, location_reader, simple |
| get_it_di_global_variable | bottom_navigation, fire_base_real_time_db, fire_storage_impl, firestore_db_impl, image_picker_adapter, image_uploader, language_translator, local_data_impl, location_crud_service, location_reader, navigation_without_context, rest_api_impl, reusable_editor, theme_setting, upload_progress_indicator |
| i_tdd | image_uploader, location_crud_service, location_reader |
| i_validator | reusable_editor, upload_progress_indicator |
| icon_data_generator | None |
| icon_data_parser | None |
| image_core | None |
| image_picker_adapter | None |
| image_uploader | None |
| json_list_data_parser | None |
| language_translator | fire_storage_impl, firestore_db_impl, image_uploader, location_crud_service, location_reader |
| loading_builder | None |
| loading_state | None |
| local_data_impl | image_uploader, rest_api_impl |
| location_crud_service | None |
| location_reader | location_crud_service |
| navigation_without_context | fire_storage_impl, firestore_db_impl, image_uploader, language_translator, location_crud_service, location_reader |
| online_indicator | app_sliver, image_picker_adapter, reusable_app_bar, reusable_image_widget, reusable_list_item |
| rest_api_impl | image_uploader |
| reusable_app_bar | None |
| reusable_bottom_sheet | None |
| reusable_button | app_sliver, reusable_app_bar, reusable_list_view, text_field_builder |
| reusable_dialog | None |
| reusable_editor | upload_progress_indicator |
| reusable_icon | None |
| reusable_image_widget | app_sliver, image_picker_adapter, reusable_app_bar, reusable_list_item |
| reusable_list_item | None |
| reusable_list_view | app_sliver |
| reusable_speed_dial | None |
| reusable_switch_btn | None |
| reusable_tab_bar | app_sliver |
| rounded_scaffold_body | None |
| simple | None |
| state_msg_builder | app_sliver, builder_state, reusable_list_view |
| submission_state | None |
| tag_builder | None |
| text_field_builder | app_sliver, reusable_app_bar, reusable_list_view |
| theme_setting | None |
| upload_progress_indicator | None |
