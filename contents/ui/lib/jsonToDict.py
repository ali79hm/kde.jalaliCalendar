import json

def process_calendar_data(data_list):
    processed = {}

    for event in data_list:
        if event['type'] == 'Afghanistan':
            continue
        month_index = event["month"] - 1  # Convert month to 0-based index
        day = event["day"]

        # Ensure the month exists in the processed dictionary
        if month_index not in processed:
            processed[month_index] = {}

        # Ensure the day exists in the month 
        if day not in processed[month_index]:
            processed[month_index][day] = []

        # Add the event as [title, holiday]
        processed[month_index][day].append([event["title"], event["holiday"]])

    return processed

if __name__ =='__main__':
    json_path = './events.json'
    with open(json_path,'r') as f:
        json_file = json.load(f)
    # print(json_file["Hijri Calendar"])
    # Processed dictionary
    processed_calendar = process_calendar_data(json_file["Hijri Calendar"])
    print(json.dumps(processed_calendar, indent=2,ensure_ascii=False))