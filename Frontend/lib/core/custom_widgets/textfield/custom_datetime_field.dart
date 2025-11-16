import 'package:chess_app/core/custom_widgets/shimmer/shimmer_field.dart';
import 'package:chess_app/core/dimens/app_dimen.dart';
import 'package:chess_app/core/dimens/dimens.dart';
import 'package:chess_app/core/style/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CustomDateTimeField extends StatefulWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final Function(String) onDateSelected;
  final bool isLoading;

  const CustomDateTimeField({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    required this.onDateSelected,
    this.isLoading = false,
  });

  @override
  State<CustomDateTimeField> createState() => _CustomDateTimeFieldState();
}

class _CustomDateTimeFieldState extends State<CustomDateTimeField> {
  bool _showDatePicker = false;
  bool _showMonthYearPicker = false;
  DateTime _selectedDate = DateTime.now();

  final List<String> _months = [
    'jan',
    'feb',
    'mar',
    'apr',
    'may',
    'jun',
    'jul',
    'aug',
    'sep',
    'oct',
    'nov',
    'dec',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isNotEmpty) {
      try {
        _selectedDate = DateFormat("dd/MM/yyyy").parse(widget.controller.text);
      } catch (_) {}
    }
  }

  void _toggleDatePicker() {
    setState(() {
      _showDatePicker = !_showDatePicker;
      _showMonthYearPicker = false;
    });
  }

  void _toggleMonthYearPicker() {
    setState(() {
      _showMonthYearPicker = !_showMonthYearPicker;
    });
  }

  void _goToPreviousMonth() {
    setState(() {
      if (_selectedDate.month == 1) {
        _selectedDate = DateTime(_selectedDate.year - 1, 12);
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      }
    });
  }

  void _goToNextMonth() {
    setState(() {
      if (_selectedDate.month == 12) {
        _selectedDate = DateTime(_selectedDate.year + 1, 1);
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
      }
    });
  }

  void _onDateSelected(int day) {
    final newDate = DateTime(_selectedDate.year, _selectedDate.month, day);
    if (newDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_selecting_date_of_birth'.tr())),
      );
      return;
    }

    setState(() {
      _selectedDate = newDate;
      widget.controller.text = DateFormat("dd/MM/yyyy").format(newDate);
      _showDatePicker = false;
    });

    widget.onDateSelected(widget.controller.text);
  }

  Widget _buildCalendarGrid() {
    final double cellSize = Dimens.d38.responsive();
    final daysInMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month + 1,
      0,
    ).day;
    final firstDayOfWeek = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    ).weekday;

    List<Widget> cells = [];

    for (int i = 1; i < firstDayOfWeek; i++) {
      cells.add(SizedBox(height: cellSize, width: cellSize));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final isSelected =
          widget.controller.text ==
          DateFormat(
            "dd/MM/yyyy",
          ).format(DateTime(_selectedDate.year, _selectedDate.month, day));
      cells.add(
        GestureDetector(
          onTap: () => _onDateSelected(day),
          child: Container(
            margin: EdgeInsets.all(Dimens.d4.responsive()),
            height: cellSize,
            width: cellSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? const Color(0xFF2F6C5A).withOpacity(0.2)
                  : Colors.transparent,
            ),
            child: Text(
              '$day',
              style: AppTextStyles.style.s16.w500.copyWith(
                color: isSelected ? const Color(0xFF2F6C5A) : Colors.black87,
              ),
            ),
          ),
        ),
      );
    }

    List<TableRow> rows = [];

    final weekDayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    rows.add(
      TableRow(
        children: weekDayKeys.map((key) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: Dimens.d8.responsive()),
              child: Text(
                key.tr(),
                style: AppTextStyles.style.s14.w500.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );

    for (int i = 0; i < cells.length; i += 7) {
      rows.add(
        TableRow(
          children: List.generate(
            7,
            (j) => i + j < cells.length
                ? cells[i + j]
                : SizedBox(height: cellSize, width: cellSize),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.d16.responsive(),
        vertical: Dimens.d10.responsive(),
      ),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: rows,
      ),
    );
  }

  Widget _buildMonthYearPicker() {
    final itemHeight = Dimens.d38.responsive();
    return SizedBox(
      height: Dimens.d286.responsive(),
      child: Row(
        children: [
          Expanded(
            child: ListWheelScrollView.useDelegate(
              controller: FixedExtentScrollController(
                initialItem: _selectedDate.month - 1,
              ),
              itemExtent: itemHeight,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedDate = DateTime(_selectedDate.year, index + 1);
                });
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  if (index < 0 || index > 11) return null;
                  final month = _months[index].tr();
                  final isSelected = index + 1 == _selectedDate.month;
                  return Center(
                    child: Text(
                      month,
                      style: AppTextStyles.style.s16.w400.copyWith(
                        color: isSelected
                            ? const Color(0xFF2F6C5A)
                            : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: ListWheelScrollView.useDelegate(
              controller: FixedExtentScrollController(
                initialItem: _selectedDate.year - 1900,
              ),
              itemExtent: itemHeight,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedDate = DateTime(1900 + index, _selectedDate.month);
                });
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final year = 1900 + index;
                  if (year > DateTime.now().year) return null;
                  final isSelected = year == _selectedDate.year;
                  return Center(
                    child: Text(
                      year.toString(),
                      style: AppTextStyles.style.s16.w400.copyWith(
                        color: isSelected
                            ? const Color(0xFF2F6C5A)
                            : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: Dimens.d12.responsive(),
          horizontal: Dimens.d16.responsive(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.title, style: AppTextStyles.style.s14.w400.grayColor),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: ShimmerField(width: Dimens.d80.responsive()),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _toggleDatePicker,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: Dimens.d12.responsive(),
              horizontal: Dimens.d16.responsive(),
            ),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.style.s14.w400.grayColor,
                ),
                const Spacer(),
                Text(
                  widget.controller.text.isEmpty
                      ? widget.hintText
                      : widget.controller.text,
                  style: AppTextStyles.style.s16.w400.copyWith(
                    color: widget.controller.text.isEmpty
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showDatePicker)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(Dimens.d12.responsive()),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.d16.responsive(),
                    vertical: Dimens.d8.responsive(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _toggleMonthYearPicker,
                        child: Row(
                          children: [
                            Text(
                              '${_months[_selectedDate.month - 1].tr()} ${_selectedDate.year}',
                              style: AppTextStyles.style.s16.w500.blackColor,
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      if (!_showMonthYearPicker)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: _goToPreviousMonth,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: _goToNextMonth,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                _showMonthYearPicker
                    ? _buildMonthYearPicker()
                    : _buildCalendarGrid(),
              ],
            ),
          ),
      ],
    );
  }
}
