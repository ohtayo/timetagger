using CSV, DataFrames, Dates

# read CSV data
cd("C:\\workspace\\timetagger")
file = "timetagger-records.csv"
record = DataFrame(CSV.File(file))

# preparation
colnames = names(record)
colnames = replace.(colnames, " "=>"")
rename!(record, colnames) # ヘッダからスペースを削る
record2 = select!(record, "duration", "tags")
record2 = record2[completecases(record2),:] # missingのある行を除外
record2.duration = convert(Array{Dates.Time}, record2.duration) # 型変換
record2.tags = convert(Array{String}, record2.tags) # 型変換
record2.duration = Dates.value.(record2.duration) ./ 1e9 ./ 3600 # Dates.Time型を時間のFloat64に変換

# タグをすべて抽出
tags = String[]
list = split.(record2[:,"tags"], " #")
for arr in list
    for str in arr
        if !isempty(str)
            append!(tags, [str])
        end
    end
end
unique!(tags) # 重複を削除
summery = DataFrame()
summery.tag = tags

# タグ別の時間を集計
time = []
for tag in tags
    idx = occursin.(tag, record2.tags)
    value = sum(record2[idx, "duration"])
    append!(time, value)
end
summery.time = time

# 保存
CSV.write("summery.csv", summery, bom=true)

